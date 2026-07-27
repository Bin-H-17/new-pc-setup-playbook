# scan-old-pc.ps1
# Old-PC scan script — New PC Setup Assistant
# Scans software usage, cache layout, environment, and Git repos
# Privacy: no upload; local report only

#Requires -Version 5.1
$ErrorActionPreference = "SilentlyContinue"

$reportPath = "$PSScriptRoot\old-pc-scan-report.md"
$userHome = $env:USERPROFILE
$userName = $env:USERNAME

Write-Host "=== Old PC scan script ===" -ForegroundColor Cyan
Write-Host "Report will be saved to: $reportPath" -ForegroundColor Green
Write-Host ""

# Report header
$report = "# Old PC scan report`n`n"
$report += "**Scan time**: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
$report += "**Username**: [USER] (redacted)`n"
$report += "**Operating system**: $([System.Environment]::OSVersion.VersionString)`n`n"

# ============================================================
# 1. Software usage (UserAssist registry)
# ============================================================
Write-Host "[1/5] Scanning software usage..." -ForegroundColor Yellow

$report += "## 1. Software usage (last 90 days)`n`n"
$report += "| Application | Last used | Run count | Path |`n"
$report += "|-------------|-----------|-----------|------|`n"

$userAssistPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist"
$cutoffDate = (Get-Date).AddDays(-90)

$softwareList = @()
Get-ChildItem $userAssistPath | ForEach-Object {
    $countPath = Join-Path $_.PSPath "Count"
    if (Test-Path $countPath) {
        Get-ItemProperty $countPath | ForEach-Object {
            $_.PSObject.Properties | Where-Object { $_.Name -notmatch "^PS" } | ForEach-Object {
                $encodedName = $_.Name
                try {
                    # ROT13 decode
                    $decoded = ""
                    foreach ($char in $encodedName.ToCharArray()) {
                        $code = [int]$char
                        if ($code -ge 65 -and $code -le 90) {
                            $decoded += [char]((($code - 65 + 13) % 26) + 65)
                        } elseif ($code -ge 97 -and $code -le 122) {
                            $decoded += [char]((($code - 97 + 13) % 26) + 97)
                        } else {
                            $decoded += $char
                        }
                    }
                    $value = $_.Value
                    if ($value -is [byte[]] -and $value.Length -ge 68) {
                        $lastUsed = [BitConverter]::ToFileTime([BitConverter]::ToInt64($value, 60))
                        if ($lastUsed -gt 0) {
                            $lastDate = [DateTime]::FromFileTime($lastUsed)
                            $runCount = [BitConverter]::ToUInt32($value, 4)
                            if ($lastDate -gt $cutoffDate -and $decoded -match "\.(exe)$") {
                                $softwareList += [PSCustomObject]@{
                                    Name = $decoded
                                    LastUsed = $lastDate
                                    RunCount = $runCount
                                }
                            }
                        }
                    }
                } catch {}
            }
        }
    }
}

$softwareList | Sort-Object LastUsed -Descending | Select-Object -First 50 | ForEach-Object {
    $name = Split-Path $_.Name -Leaf
    $path = $_.Name -replace [regex]::Escape($userHome), "[USER]"
    $report += "| $name | $($_.LastUsed.ToString('yyyy-MM-dd')) | $($_.RunCount) | $path |`n"
}
$report += "`n"
Write-Host "  Found $($softwareList.Count) recently used applications" -ForegroundColor Green

# ============================================================
# 2. Cache layout (large AppData folders)
# ============================================================
Write-Host "[2/5] Scanning cache layout..." -ForegroundColor Yellow

$report += "## 2. Cache layout (> 500MB folders)`n`n"

$appDataPaths = @(
    @{ Path = "$userHome\AppData\Local"; Label = "AppData\Local" },
    @{ Path = "$userHome\AppData\Roaming"; Label = "AppData\Roaming" },
    @{ Path = "$userHome\AppData\LocalLow"; Label = "AppData\LocalLow" }
)

foreach ($adp in $appDataPaths) {
    if (Test-Path $adp.Path) {
        $report += "`n### $($adp.Label)`n`n"
        $report += "| Folder | Size (MB) |`n"
        $report += "|--------|-----------|`n"
        $folders = Get-ChildItem $adp.Path -Directory -Force | ForEach-Object {
            $size = (Get-ChildItem $_.FullName -Recurse -Force -ErrorAction SilentlyContinue |
                     Measure-Object -Property Length -Sum).Sum
            [PSCustomObject]@{
                Name = $_.Name
                SizeMB = [math]::Round($size / 1MB, 2)
            }
        } | Where-Object { $_.SizeMB -gt 500 } | Sort-Object SizeMB -Descending

        foreach ($f in $folders) {
            $report += "| $($f.Name) | $($f.SizeMB) |`n"
        }
        $total = ($folders | Measure-Object -Property SizeMB -Sum).Sum
        if ($null -eq $total) { $total = 0 }
        $report += "| **Total** | **$total** |`n"
    }
}
$report += "`n"

Write-Host "  Cache scan complete" -ForegroundColor Green

# ============================================================
# 3. Environment detection
# ============================================================
Write-Host "[3/5] Detecting environment..." -ForegroundColor Yellow

$report += "## 3. Environment`n`n"

# conda
$report += "### conda`n`n"
$condaPaths = @(
    "$userHome\anaconda3\Scripts\conda.exe",
    "$userHome\miniconda3\Scripts\conda.exe",
    "C:\ProgramData\anaconda3\Scripts\conda.exe",
    "C:\ProgramData\miniconda3\Scripts\conda.exe"
)
$condaFound = $false
foreach ($cp in $condaPaths) {
    if (Test-Path $cp) {
        $condaFound = $true
        $condaVersion = & $cp --version 2>&1
        $condaEnvs = & $cp env list 2>&1
        $report += "- **Install path**: $($cp -replace [regex]::Escape($userHome), '[USER]')`n"
        $report += "- **Version**: $condaVersion`n"
        $report += "- **Environments**:`n"
        $report += "```````n$condaEnvs`n```````n"
    }
}
if (-not $condaFound) { $report += "- conda not detected`n" }
$report += "`n"

# Python
$report += "### Python`n`n"
$pythonCmd = Get-Command python -ErrorAction SilentlyContinue
if ($pythonCmd) {
    $pyVersion = python --version 2>&1
    $report += "- **Version**: $pyVersion`n"
    $report += "- **Path**: $($pythonCmd.Source -replace [regex]::Escape($userHome), '[USER]')`n"
} else {
    $report += "- python not found on PATH`n"
}
$report += "`n"

# CUDA
$report += "### CUDA`n`n"
$nvidiaSmi = Get-Command nvidia-smi -ErrorAction SilentlyContinue
if ($nvidiaSmi) {
    $gpuInfo = nvidia-smi 2>&1 | Select-Object -First 15
    $report += "- **nvidia-smi output**:`n"
    $report += "```````n$gpuInfo`n```````n"
} else {
    $report += "- nvidia-smi not found (no NVIDIA driver or no discrete GPU)`n"
}
$report += "`n"

# Node.js
$report += "### Node.js`n`n"
$nodeCmd = Get-Command node -ErrorAction SilentlyContinue
if ($nodeCmd) {
    $nodeVersion = node --version 2>&1
    $npmVersion = npm --version 2>&1
    $report += "- **Node.js version**: $nodeVersion`n"
    $report += "- **npm version**: $npmVersion`n"
} else {
    $report += "- Node.js not detected`n"
}
$report += "`n"

# Git
$report += "### Git`n`n"
$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if ($gitCmd) {
    $gitVersion = git --version 2>&1
    $report += "- **Git version**: $gitVersion`n"
    $gitUser = git config --global user.name 2>&1
    if ($gitUser -and ($gitUser -notmatch "error|unknown")) {
        $report += "- **Git user.name**: [REDACTED]`n"
    } else {
        $report += "- **Git user.name**: (not set or N/A)`n"
    }
} else {
    $report += "- Git not detected`n"
}
$report += "`n"

# LaTeX
$report += "### LaTeX`n`n"
$latexPaths = @(
    "$userHome\AppData\Local\Programs\MiKTeX",
    "C:\Program Files\MiKTeX",
    "C:\texlive"
)
$latexFound = $false
foreach ($lp in $latexPaths) {
    if (Test-Path $lp) {
        $latexFound = $true
        $report += "- **Detected**: $($lp -replace [regex]::Escape($userHome), '[USER]')`n"
    }
}
if (-not $latexFound) { $report += "- LaTeX not detected`n" }
$report += "`n"

# MATLAB
$report += "### MATLAB`n`n"
$matlabPaths = @("C:\Program Files\MATLAB", "D:\MATLAB", "D:\Program Files\MATLAB")
$matlabFound = $false
foreach ($mp in $matlabPaths) {
    if (Test-Path $mp) {
        $matlabFound = $true
        $versions = Get-ChildItem $mp -Directory
        foreach ($v in $versions) {
            $report += "- **Detected**: $($v.FullName)`n"
        }
    }
}
if (-not $matlabFound) { $report += "- MATLAB not detected`n" }
$report += "`n"

Write-Host "  Environment detection complete" -ForegroundColor Green

# ============================================================
# 4. Git repositories
# ============================================================
Write-Host "[4/5] Scanning Git repositories..." -ForegroundColor Yellow

$report += "## 4. Git repositories (.git folders)`n`n"
$report += "| Repository path | Remote URL |`n"
$report += "|-----------------|------------|`n"

$searchPaths = @("D:\", "$userHome\Desktop", "$userHome\Documents")
$gitRepos = @()
foreach ($sp in $searchPaths) {
    if (Test-Path $sp) {
        $found = Get-ChildItem $sp -Recurse -Directory -Filter ".git" -Depth 4 -ErrorAction SilentlyContinue
        foreach ($repo in $found) {
            $repoPath = Split-Path $repo.FullName -Parent
            $remoteRaw = git -C $repoPath remote get-url origin 2>$null
            if (-not $remoteRaw) {
                $remoteRaw = (git -C $repoPath remote -v 2>$null | Select-Object -First 1)
            }
            # Strip credentials and soften personal host paths
            $remoteSafe = "$remoteRaw"
            $remoteSafe = $remoteSafe -replace '://[^@/]+@', '://[REDACTED]@'
            $remoteSafe = $remoteSafe -replace [regex]::Escape($userHome), '[USER]'
            if ([string]::IsNullOrWhiteSpace($remoteSafe)) { $remoteSafe = "(no remote)" }
            $gitRepos += [PSCustomObject]@{
                Path = $repoPath -replace [regex]::Escape($userHome), '[USER]'
                Remote = $remoteSafe
            }
        }
    }
}

foreach ($r in $gitRepos) {
    $report += "| $($r.Path) | $($r.Remote) |`n"
}
if ($gitRepos.Count -eq 0) {
    $report += "| No repositories found | - |`n"
}
$report += "`n"
Write-Host "  Found $($gitRepos.Count) Git repositories" -ForegroundColor Green

# ============================================================
# 5. SSH configuration (existence only; no content read)
# ============================================================
Write-Host "[5/5] Checking SSH configuration..." -ForegroundColor Yellow

$report += "## 5. SSH configuration`n`n"
$sshPath = "$userHome\.ssh"
if (Test-Path $sshPath) {
    $sshFiles = Get-ChildItem $sshPath -Force
    $report += "| File name | Present |`n"
    $report += "|-----------|---------|`n"
    foreach ($f in $sshFiles) {
        $report += "| $($f.Name) | Yes |`n"
    }
    $report += "`n**Note**: For privacy, only file names are listed — key and config contents are not read. Review file names before sharing this report.`n"
} else {
    $report += "No .ssh folder detected`n"
}
$report += "`n"

Write-Host "  SSH check complete" -ForegroundColor Green

# ============================================================
# Save report
# ============================================================
$report | Out-File -FilePath $reportPath -Encoding utf8 -Force

Write-Host ""
Write-Host "=== Scan complete ===" -ForegroundColor Cyan
Write-Host "Report saved to: $reportPath" -ForegroundColor Green
Write-Host ""
Write-Host "Next step: Share the report with AI to generate a migration plan" -ForegroundColor Yellow
