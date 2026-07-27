# setup-env.ps1
# One-shot environment setup — New PC Setup Assistant
# Creates directory layout + user env vars + optional system tweaks
# Safety: TEMP/TMP, Defender exclusions, hibernation off are opt-in

#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$DataDrive = "D:",
    [string]$KnowledgeDrive = "O:",
    [switch]$DryRun,
    [switch]$SetTempToDataDrive,
    [switch]$AddDefenderExclusions,
    [switch]$DisableHibernation,
    [switch]$EnableHighPerformancePower,
    [switch]$WriteCondarc,
    [switch]$ConfigureNpm
)

$ErrorActionPreference = "Stop"

# ============================================================
# Configuration
# ============================================================
$SystemDrive = "C:"
$HasKnowledgePartition = Test-Path $KnowledgeDrive

Write-Host "=== Environment setup script ===" -ForegroundColor Cyan
Write-Host "User: [USER] (real username not printed)" -ForegroundColor Green
Write-Host "System drive: $SystemDrive" -ForegroundColor Green
Write-Host "Data drive: $DataDrive" -ForegroundColor Green
if ($HasKnowledgePartition) {
    Write-Host "Knowledge drive: $KnowledgeDrive" -ForegroundColor Green
} else {
    Write-Host "Knowledge: $DataDrive\Knowledge (no dedicated partition)" -ForegroundColor Green
}
if ($DryRun) { Write-Host "Mode: DryRun (no writes)" -ForegroundColor Yellow }
Write-Host ""

function Set-UserEnv {
    param([string]$Name, [string]$Value)
    if ($DryRun) {
        Write-Host "  [DryRun] Would set $Name = $Value" -ForegroundColor DarkYellow
        return
    }
    [Environment]::SetEnvironmentVariable($Name, $Value, "User")
    Write-Host "  Set $Name = $Value" -ForegroundColor DarkGray
}

# ============================================================
# 1. Create directory structure
# ============================================================
Write-Host "[1/4] Creating directory structure..." -ForegroundColor Yellow

$directories = @(
    "$DataDrive\Dotfiles",
    "$DataDrive\Dotfiles\Cursor",
    "$DataDrive\Dotfiles\Cursor\UserData",
    "$DataDrive\Dotfiles\.ssh",
    "$DataDrive\Caches",
    "$DataDrive\Caches\conda",
    "$DataDrive\Caches\conda\envs",
    "$DataDrive\Caches\conda\pkgs",
    "$DataDrive\Caches\pip",
    "$DataDrive\Caches\npm-global",
    "$DataDrive\Caches\uv",
    "$DataDrive\Caches\huggingface",
    "$DataDrive\Caches\Cursor",
    "$DataDrive\Caches\Cursor\Extensions",
    "$DataDrive\Caches\Trae",
    "$DataDrive\Caches\Temp",
    "$DataDrive\Workspace",
    "$DataDrive\Datasets",
    "$DataDrive\Downloads",
    "$DataDrive\Migration",
    $(if ($HasKnowledgePartition) { "$KnowledgeDrive" } else { "$DataDrive\Knowledge" })
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        if ($DryRun) {
            Write-Host "  [DryRun] Would create: $dir" -ForegroundColor DarkYellow
        } else {
            New-Item -ItemType Directory -Force -Path $dir | Out-Null
            Write-Host "  Created: $dir" -ForegroundColor DarkGray
        }
    }
}
Write-Host "  Directory structure ready" -ForegroundColor Green
Write-Host ""

# ============================================================
# 2. User environment variables
# ============================================================
Write-Host "[2/4] Setting environment variables..." -ForegroundColor Yellow

$envVars = @(
    @{ Name = "PIP_CACHE_DIR"; Value = "$DataDrive\Caches\pip" },
    @{ Name = "UV_CACHE_DIR"; Value = "$DataDrive\Caches\uv" },
    @{ Name = "HF_HOME"; Value = "$DataDrive\Caches\huggingface" },
    @{ Name = "TORCH_HOME"; Value = "$DataDrive\Caches\torch" },
    @{ Name = "NPM_CONFIG_CACHE"; Value = "$DataDrive\Caches\npm" },
    @{ Name = "NPM_CONFIG_PREFIX"; Value = "$DataDrive\Caches\npm-global" },
    @{ Name = "COREPACK_HOME"; Value = "$DataDrive\Caches\corepack" },
    @{ Name = "PNPM_HOME"; Value = "$DataDrive\Caches\pnpm" },
    @{ Name = "RUSTUP_HOME"; Value = "$DataDrive\Caches\rustup" },
    @{ Name = "CARGO_HOME"; Value = "$DataDrive\Caches\cargo" },
    @{ Name = "GOPATH"; Value = "$DataDrive\Workspace\go" },
    @{ Name = "GOPROXY"; Value = "https://goproxy.cn,direct" }
)

if ($SetTempToDataDrive) {
    Write-Host "  Warning: pointing TEMP/TMP to data drive may break some installers" -ForegroundColor Yellow
    $envVars += @{ Name = "TEMP"; Value = "$DataDrive\Caches\Temp" }
    $envVars += @{ Name = "TMP"; Value = "$DataDrive\Caches\Temp" }
}

foreach ($ev in $envVars) {
    Set-UserEnv -Name $ev.Name -Value $ev.Value
}

if ($WriteCondarc) {
    $condarcPath = "$env:USERPROFILE\.condarc"
    $condarcContent = @"
channels:
  - defaults
show_channel_urls: true
default_channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
custom_channels:
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
envs_dirs:
  - $DataDrive\Caches\conda\envs
pkgs_dirs:
  - $DataDrive\Caches\conda\pkgs
"@
    if ($DryRun) {
        Write-Host "  [DryRun] Would write $condarcPath" -ForegroundColor DarkYellow
    } else {
        if (Test-Path $condarcPath) {
            Copy-Item $condarcPath "$condarcPath.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')" -Force
        }
        $condarcContent | Out-File -FilePath $condarcPath -Encoding utf8 -Force
        Write-Host "  Wrote .condarc (backed up existing file if present)" -ForegroundColor DarkGray
    }
} else {
    Write-Host "  Skipping .condarc (pass -WriteCondarc to enable)" -ForegroundColor DarkGray
}

if ($ConfigureNpm) {
    if ($DryRun) {
        Write-Host "  [DryRun] Would configure npm cache/prefix" -ForegroundColor DarkYellow
    } else {
        npm config set cache "$DataDrive\Caches\npm" 2>$null
        npm config set prefix "$DataDrive\Caches\npm-global" 2>$null
        $npmGlobalPath = "$DataDrive\Caches\npm-global"
        $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        if ($userPath -notlike "*$npmGlobalPath*") {
            [Environment]::SetEnvironmentVariable("PATH", "$userPath;$npmGlobalPath", "User")
        }
        Write-Host "  Configured npm cache + prefix" -ForegroundColor DarkGray
    }
} else {
    Write-Host "  Skipping npm (pass -ConfigureNpm to enable)" -ForegroundColor DarkGray
}

Write-Host "  Environment variables done" -ForegroundColor Green
Write-Host ""

# ============================================================
# 3. System tweaks (all opt-in)
# ============================================================
Write-Host "[3/4] System tweaks (only flags you enable)..." -ForegroundColor Yellow

if ($DisableHibernation) {
    if ($DryRun) { Write-Host "  [DryRun] powercfg -h off" -ForegroundColor DarkYellow }
    else {
        powercfg -h off 2>$null
        Write-Host "  Disabled hibernation" -ForegroundColor DarkGray
    }
} else {
    Write-Host "  Skipping hibernation (use -DisableHibernation)" -ForegroundColor DarkGray
}

if ($EnableHighPerformancePower) {
    if ($DryRun) { Write-Host "  [DryRun] Enable high performance power plan" -ForegroundColor DarkYellow }
    else {
        powercfg -duplicatescheme 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null
        Write-Host "  Attempted to enable high performance power plan" -ForegroundColor DarkGray
    }
} else {
    Write-Host "  Skipping power plan (use -EnableHighPerformancePower)" -ForegroundColor DarkGray
}

if ($AddDefenderExclusions) {
    Write-Host "  Warning: Defender exclusions reduce real-time protection on those paths" -ForegroundColor Yellow
    if ($DryRun) {
        Write-Host "  [DryRun] Would exclude Caches/Datasets/Workspace" -ForegroundColor DarkYellow
    } else {
        Add-MpPreference -ExclusionPath "$DataDrive\Caches" 2>$null
        Add-MpPreference -ExclusionPath "$DataDrive\Datasets" 2>$null
        Add-MpPreference -ExclusionPath "$DataDrive\Workspace" 2>$null
        Write-Host "  Added Defender exclusions" -ForegroundColor DarkGray
    }
} else {
    Write-Host "  Skipping Defender exclusions (use -AddDefenderExclusions)" -ForegroundColor DarkGray
}

Write-Host "  System tweak step finished" -ForegroundColor Green
Write-Host ""

# ============================================================
# 4. Verification
# ============================================================
Write-Host "[4/4] Verifying configuration..." -ForegroundColor Yellow
$checkVars = @("PIP_CACHE_DIR", "UV_CACHE_DIR", "HF_HOME", "NPM_CONFIG_PREFIX")
foreach ($cv in $checkVars) {
    $val = [Environment]::GetEnvironmentVariable($cv, "User")
    if ($val) {
        Write-Host "    OK $cv = $val" -ForegroundColor Green
    } else {
        Write-Host "    (not set) $cv" -ForegroundColor DarkGray
    }
}

Write-Host ""
Write-Host "=== Done ===" -ForegroundColor Cyan
Write-Host "Tip: Open a new terminal (or reboot) for env changes to apply." -ForegroundColor Yellow
Write-Host "Example: .\setup-env.ps1 -DataDrive D: -WriteCondarc -ConfigureNpm -DryRun" -ForegroundColor Green
