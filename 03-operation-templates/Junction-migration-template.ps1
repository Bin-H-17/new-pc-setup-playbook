<#
.SYNOPSIS
    Generic Junction migration script template — move C: AppData subdirectories to D: and create Junction links

.DESCRIPTION
    This script implements the "Plan B" drive-letter migration strategy:
    - APP stays on C: (keeps the system drive clean)
    - Data/cache moves to D: (frees C: capacity)
    - Junction links bridge the two (apps still access paths normally)

    ⚠️ Important safety notes:
    1. Junctioning an entire directory is less safe than junctioning Cache subdirectories only
       - Recommended: junction only Cache / Logs / large subdirectories
       - Use with caution: junctioning the entire AppData\Roaming\<App> directory
    2. Close apps that hold locks on the target paths before running
    3. Back up before executing; this script provides automatic Backup-Path backups
    4. Run as Administrator (required for system-level copy/delete; mklink /J itself does not require admin)

.PARAMETER Source
    Absolute path on C: to migrate (e.g. C:\Users\xxx\AppData\Roaming\Trae CN)

.PARAMETER Target
    Destination path on D: (e.g. D:\Caches\Trae\Trae CN)

.PARAMETER ProcessName
    Optional: process name to check before running (without .exe)
    If the process is running, the script prompts you to close it first

.PARAMETER DryRun
    Switch: simulate only, no changes — for dry runs

.PARAMETER Confirm
    Required for live (non-DryRun) runs. Without -Confirm, the script refuses to copy/delete/create junctions.

.PARAMETER Restore
    Switch: restore mode — remove the Junction and move data back to the original C: location

.EXAMPLE
    # Standard usage: migrate Trae CN config directory
    .\Junction-migration-template.ps1 `
        -Source "C:\Users\xxx\AppData\Roaming\Trae CN" `
        -Target "D:\Caches\Trae\Trae CN" `
        -ProcessName "Trae" `
        -Confirm

.EXAMPLE
    # Migrate TRAE SOLO CN Cache subdirectory (recommended — junction Cache only is safer)
    .\Junction-migration-template.ps1 `
        -Source "C:\Users\xxx\AppData\Roaming\TRAE SOLO CN\Cache" `
        -Target "D:\Caches\Trae\TRAE SOLO CN\Cache" `
        -ProcessName "Trae" `
        -Confirm

.EXAMPLE
    # DryRun preview, no actual changes
    .\Junction-migration-template.ps1 -Source "..." -Target "..." -DryRun

.EXAMPLE
    # Restore: remove Junction and move data back to C:
    .\Junction-migration-template.ps1 -Source "..." -Target "..." -Restore -Confirm

.NOTES
    Author : Bin-H-17
    License: MIT
    Version: 1.0.0
    Warning: Junction only the Cache subdir is safer than Junctioning the entire app directory.
    Note   : `mklink /J` itself does NOT require admin privileges. This script declares
             `#Requires -RunAsAdministrator` because it performs system-level file
             copy/delete operations, not because Junction requires it.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$Source,

    [Parameter(Mandatory=$true, Position=1)]
    [string]$Target,

    [Parameter(Mandatory=$false)]
    [string]$ProcessName,

    [switch]$DryRun,

    [switch]$Confirm,

    [switch]$Restore
)

#Requires -RunAsAdministrator
#Requires -Version 5.1

$ErrorActionPreference = 'Stop'
$script:BackupSuffix = ".bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')"

if (-not $DryRun -and -not $Confirm) {
    Write-Host "Refusing live run without -Confirm. Preview first with -DryRun, then re-run with -Confirm." -ForegroundColor Red
    throw "Missing -Confirm for non-DryRun execution."
}

# ==================== Helper Functions ====================

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet('INFO','WARN','ERROR','SUCCESS')]
        [string]$Level = 'INFO'
    )
    $color = switch ($Level) {
        'INFO'    { 'Cyan' }
        'WARN'    { 'Yellow' }
        'ERROR'   { 'Red' }
        'SUCCESS' { 'Green' }
    }
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] [$Level] $Message" -ForegroundColor $color
}

function Test-ProcessRunning {
    param([string]$Name)
    if ([string]::IsNullOrWhiteSpace($Name)) { return $false }
    $procs = Get-Process -Name $Name -ErrorAction SilentlyContinue
    return ($procs.Count -gt 0)
}

function Test-PathIsJunction {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $false }
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $false }
    return ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0
}

function Backup-Path {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Log "Path does not exist, no backup needed: $Path" 'WARN'
        return $null
    }
    $backup = "$Path$script:BackupSuffix"
    Write-Log "Backing up: $Path -> $backup"
    Copy-Item -LiteralPath $Path -Destination $backup -Recurse -Force -ErrorAction Stop
    Write-Log "Backup created: $backup" 'SUCCESS'
    return $backup
}

function Get-FileCount {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return 0 }
    return (Get-ChildItem -LiteralPath $Path -Recurse -File -Force -ErrorAction SilentlyContinue).Count
}

# ==================== Main Migration Function ====================

function Move-AppDataToJunction {
    <#
        Main flow: move $Source to $Target, then create a Junction at $Source pointing to $Target
    #>
    Write-Log "==== Junction Migration Start ====" 'INFO'
    Write-Log "Source : $Source"
    Write-Log "Target : $Target"
    Write-Log "DryRun : $DryRun"

    # === 1. Parameter validation ===
    if (-not (Test-Path -LiteralPath $Source)) {
        Write-Log "Source path does not exist: $Source" 'ERROR'
        throw "Source path does not exist: $Source"
    }

    $sourceItem = Get-Item -LiteralPath $Source -Force
    if (-not $sourceItem.PSIsContainer) {
        Write-Log "Source must be a directory, not a file: $Source" 'ERROR'
        throw "Source must be a directory: $Source"
    }

    if (Test-PathIsJunction -Path $Source) {
        Write-Log "Source is already a Junction. Aborting to prevent double-Junction." 'ERROR'
        throw "Source is already a Junction: $Source"
    }

    # === 2. Process lock check ===
    if ($ProcessName) {
        if (Test-ProcessRunning -Name $ProcessName) {
            Write-Log "Process '$ProcessName' is still running. Please close it before continuing." 'ERROR'
            throw "Process '$ProcessName' is running. Close it first."
        } else {
            Write-Log "Process '$ProcessName' is not running. OK." 'SUCCESS'
        }
    } else {
        Write-Log "No ProcessName specified, skipping process check." 'WARN'
    }

    # === 3. Target path check ===
    if (Test-Path -LiteralPath $Target) {
        Write-Log "Target already exists: $Target" 'WARN'
        Write-Log "Will create backup of existing target before proceeding." 'WARN'
    }

    # === 4. DryRun preview ===
    if ($DryRun) {
        Write-Log "[DryRun] Would backup source: $Source" 'INFO'
        Write-Log "[DryRun] Would copy $Source -> $Target" 'INFO'
        Write-Log "[DryRun] Would remove $Source" 'INFO'
        Write-Log "[DryRun] Would create Junction: $Source -> $Target" 'INFO'
        Write-Log "[DryRun] No changes made." 'SUCCESS'
        return
    }

    # === 5. Backup source directory ===
    $backupPath = Backup-Path -Path $Source

    try {
        # === 6. Create target parent directory ===
        $targetParent = Split-Path -Parent $Target
        if (-not (Test-Path -LiteralPath $targetParent)) {
            Write-Log "Creating target parent directory: $targetParent"
            New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
        }

        # === 7. If target exists, back it up first ===
        if (Test-Path -LiteralPath $Target) {
            $targetBackup = Backup-Path -Path $Target
            Write-Log "Removing existing target after backup: $Target" 'WARN'
            Remove-Item -LiteralPath $Target -Recurse -Force -ErrorAction Stop
        }

        # === 8. Copy source to target ===
        Write-Log "Copying: $Source -> $Target"
        Copy-Item -LiteralPath $Source -Destination $Target -Recurse -Force -ErrorAction Stop
        Write-Log "Copy completed." 'SUCCESS'

        # === 9. Verify target integrity (rough: compare file counts) ===
        $sourceFileCount = Get-FileCount -Path $Source
        $targetFileCount = Get-FileCount -Path $Target
        if ($sourceFileCount -ne $targetFileCount) {
            Write-Log "File count mismatch: source=$sourceFileCount, target=$targetFileCount" 'ERROR'
            throw "File count mismatch — aborting before removing source."
        }
        Write-Log "File count verified: $targetFileCount files." 'SUCCESS'

        # === 10. Remove source directory ===
        Write-Log "Removing source: $Source"
        Remove-Item -LiteralPath $Source -Recurse -Force -ErrorAction Stop

        # === 11. Create Junction ===
        Write-Log "Creating Junction: $Source -> $Target"
        New-Item -ItemType Junction -Path $Source -Target $Target -ErrorAction Stop | Out-Null

        # === 12. Verify Junction ===
        if (-not (Test-PathIsJunction -Path $Source)) {
            Write-Log "Junction creation verification failed." 'ERROR'
            throw "Junction not properly created at: $Source"
        }

        Write-Log "==== Migration Success ====" 'SUCCESS'
        Write-Log "Junction created: $Source -> $Target"
        Write-Log "Backup at: $backupPath"
        Write-Log "Verify your app works correctly, then you can delete the backup manually."
    }
    catch {
        Write-Log "Migration failed: $_" 'ERROR'
        Write-Log "Attempting to restore from backup: $backupPath"
        try {
            if ($backupPath -and (Test-Path -LiteralPath $backupPath)) {
                if (Test-Path -LiteralPath $Source) {
                    Remove-Item -LiteralPath $Source -Recurse -Force -ErrorAction SilentlyContinue
                }
                Copy-Item -LiteralPath $backupPath -Destination $Source -Recurse -Force -ErrorAction Stop
                Write-Log "Restored from backup." 'SUCCESS'
            }
        }
        catch {
            Write-Log "RESTORE FAILED: $_" 'ERROR'
            Write-Log "Manual recovery needed. Backup at: $backupPath" 'ERROR'
        }
        throw
    }
}

# ==================== Restore Function ====================

function Restore-Junction {
    <#
        Restore mode: remove the Junction and move data from D: back to the original C: location
    #>
    Write-Log "==== Junction Restore Mode ====" 'INFO'
    Write-Log "Source (Junction): $Source"
    Write-Log "Target (Real data): $Target"

    if (-not (Test-PathIsJunction -Path $Source)) {
        Write-Log "Source is NOT a Junction. Nothing to restore." 'ERROR'
        throw "Source is not a Junction: $Source"
    }

    if (-not (Test-Path -LiteralPath $Target)) {
        Write-Log "Target does not exist: $Target" 'ERROR'
        throw "Target data missing: $Target"
    }

    if ($DryRun) {
        Write-Log "[DryRun] Would remove Junction: $Source" 'INFO'
        Write-Log "[DryRun] Would copy $Target -> $Source" 'INFO'
        Write-Log "[DryRun] No changes made." 'SUCCESS'
        return
    }

    # Check for locking processes
    if ($ProcessName -and (Test-ProcessRunning -Name $ProcessName)) {
        Write-Log "Process '$ProcessName' is running. Close it first." 'ERROR'
        throw "Process '$ProcessName' is running."
    }

    try {
        # 1. Remove Junction
        Write-Log "Removing Junction: $Source"
        Remove-Item -LiteralPath $Source -Force -ErrorAction Stop

        # 2. Copy data from Target back to Source
        Write-Log "Copying back: $Target -> $Source"
        Copy-Item -LiteralPath $Target -Destination $Source -Recurse -Force -ErrorAction Stop

        # 3. Verify
        $sourceCount = Get-FileCount -Path $Source
        $targetCount = Get-FileCount -Path $Target
        if ($sourceCount -ne $targetCount) {
            Write-Log "File count mismatch after restore: source=$sourceCount, target=$targetCount" 'WARN'
        } else {
            Write-Log "File count verified: $sourceCount files." 'SUCCESS'
        }

        Write-Log "==== Restore Success ====" 'SUCCESS'
        Write-Log "Data is back at: $Source"
        Write-Log "Junction removed. Target still at: $Target (delete manually if no longer needed)."
    }
    catch {
        Write-Log "Restore failed: $_" 'ERROR'
        throw
    }
}

# ==================== Entry Point ====================

Write-Log "new-pc-setup-playbook :: Junction Migration Template v1.0.0" 'INFO'
Write-Log "WARNING: Junction only the Cache subdir is safer than Junctioning the entire app directory." 'WARN'

if ($Restore) {
    Restore-Junction -Source $Source -Target $Target
} else {
    Move-AppDataToJunction -Source $Source -Target $Target
}
