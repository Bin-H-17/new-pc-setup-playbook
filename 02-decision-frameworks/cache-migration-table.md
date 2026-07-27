# Cache Migration Decision Table

> Core operation of Plan B: keep apps on C:, move caches to D:.
> But not every cache should move — classify by two dimensions: **large volume** and **configurable**.

---

## 1. Three Categories

| Category | Criteria | Action | Examples |
|----------|----------|--------|----------|
| **Must change** | Large volume + configurable (env vars / config files) | Migrate to D: immediately | conda / pip / HF / npm / uv / Cursor / Cargo |
| **Should change** | Large volume + changeable in app settings | Change after foundation is set | WeChat / QQ / Feishu / Chrome downloads / Zotero |
| **No change needed** | Small volume + hard to change (registry / forced paths) | Leave on C:, clean periodically | Listary / Everything / Snipaste / Windows temp / browser cache |

> Rule of thumb: **Size in GB tells you if it's big; docs tell you if it's changeable**.

---

## 2. Must Change: Developer Tooling

### 2.1 conda Environments

| Item | Details |
|------|---------|
| Default location | `C:\Users\<USER>\.conda\envs\` or `C:\Miniconda3\envs\` |
| Size estimate | 2–10 GB per environment; research machines often have 5+ envs, totaling 30–80 GB |
| How to change | Configure `.condarc` |

**Setup steps**:

```powershell
# 1. Create target directories
mkdir D:\Environments\conda\envs
mkdir D:\Environments\conda\pkgs

# 2. Edit .condarc (in user home)
notepad $env:USERPROFILE\.condarc
```

`.condarc` contents:

```yaml
envs_dirs:
  - D:\Environments\conda\envs
pkgs_dirs:
  - D:\Environments\conda\pkgs
channels:
  - defaults
```

### 2.2 pip Cache

| Item | Details |
|------|---------|
| Default location | `C:\Users\<USER>\AppData\Local\pip\Cache\` |
| Size estimate | 1–5 GB |
| How to change | Environment variable `PIP_CACHE_DIR` |

```powershell
# Set environment variable (user-level, permanent)
[System.Environment]::SetEnvironmentVariable("PIP_CACHE_DIR", "D:\Caches\pip", "User")

# Temporary for current session
$env:PIP_CACHE_DIR = "D:\Caches\pip"

# Verify
pip cache dir
```

### 2.3 uv Cache (recommended high-speed pip alternative)

| Item | Details |
|------|---------|
| Default location | `C:\Users\<USER>\AppData\Local\uv\cache\` |
| Size estimate | 2–10 GB |
| How to change | Environment variable `UV_CACHE_DIR` |

```powershell
[System.Environment]::SetEnvironmentVariable("UV_CACHE_DIR", "D:\Caches\uv", "User")
$env:UV_CACHE_DIR = "D:\Caches\uv"

# Verify
uv cache dir
```

### 2.4 HuggingFace Model Cache

| Item | Details |
|------|---------|
| Default location | `C:\Users\<USER>\.cache\huggingface\` |
| Size estimate | **Very large** — 1–50 GB per model, often 50–500 GB total |
| How to change | Environment variable `HF_HOME` |

```powershell
[System.Environment]::SetEnvironmentVariable("HF_HOME", "D:\Caches\huggingface", "User")
$env:HF_HOME = "D:\Caches\huggingface"

# Also set hub cache (legacy variable name)
[System.Environment]::SetEnvironmentVariable("TRANSFORMERS_CACHE", "D:\Caches\huggingface\hub", "User")

# Verify
python -c "from huggingface_hub import constants; print(constants.HF_HUB_CACHE)"
```

### 2.5 npm Cache

| Item | Details |
|------|---------|
| Default location | `C:\Users\<USER>\AppData\Local\npm-cache\` or `C:\Users\<USER>\.npm\` |
| Size estimate | 1–10 GB |
| How to change | Environment variable `NPM_CONFIG_CACHE` + npm prefix |

```powershell
# Cache directory
[System.Environment]::SetEnvironmentVariable("NPM_CONFIG_CACHE", "D:\Caches\npm", "User")

# Global install directory (optional)
[System.Environment]::SetEnvironmentVariable("NPM_CONFIG_PREFIX", "D:\Caches\npm\prefix", "User")

# Verify
npm config get cache
```

### 2.6 Cursor User Data + Extensions

| Item | Details |
|------|---------|
| Default location | `C:\Users\<USER>\AppData\Roaming\Cursor\` and `C:\Users\<USER>\.cursor\extensions\` |
| Size estimate | 1–5 GB |
| How to change | Launch arguments (no env var support) |

**Setup steps**:

1. Create directories:
```powershell
mkdir D:\Dotfiles\Cursor\UserData
mkdir D:\Caches\Cursor\Extensions
```

2. Edit Cursor desktop shortcut → Right-click Properties → Target, append arguments:

```
"C:\Program Files\Cursor\Cursor.exe" --user-data-dir=D:\Dotfiles\Cursor\UserData --extensions-dir=D:\Caches\Cursor\Extensions
```

3. Taskbar-pinned version: unpin → modify → re-pin

### 2.7 Trae User Data + Extensions

Same logic as Cursor (Electron + VS Code core):

```
"C:\Program Files\Trae\Trae.exe" --user-data-dir=D:\Dotfiles\Trae\UserData --extensions-dir=D:\Caches\Trae\Extensions
```

### 2.8 Cargo / Rust Cache

| Item | Details |
|------|---------|
| Default location | `C:\Users\<USER>\.cargo\` |
| Size estimate | 1–10 GB |
| How to change | Environment variable `CARGO_HOME` |

```powershell
[System.Environment]::SetEnvironmentVariable("CARGO_HOME", "D:\Caches\cargo", "User")
$env:CARGO_HOME = "D:\Caches\cargo"
```

### 2.9 Torch / Torchaudio / Torchvision Cache

```powershell
# Torch hub cache
[System.Environment]::SetEnvironmentVariable("TORCH_HOME", "D:\Caches\torch", "User")
```

---

## 3. Should Change: Social Apps / Large Files

### 3.1 WeChat

| Item | Details |
|------|---------|
| Default location | `C:\Users\<USER>\Documents\WeChat Files\` |
| Size estimate | 5–50 GB |
| How to change | WeChat Settings → File Management → Change |

**Steps**: WeChat → Settings → File Management → Change → `D:\Data\WeChat`

### 3.2 QQ

| Item | Details |
|------|---------|
| Default location | `C:\Users\<USER>\Documents\Tencent Files\` |
| Size estimate | 5–30 GB |
| How to change | QQ → Settings → File Management → Personal folder |

### 3.3 Feishu

| Item | Details |
|------|---------|
| Default location | `C:\Users\<USER>\AppData\Local\Lark\SDK\` |
| Size estimate | 2–20 GB |
| How to change | Feishu → Settings → General → File storage location |

### 3.4 Chrome Downloads

| Item | Details |
|------|---------|
| Default location | `C:\Users\<USER>\Downloads\` |
| Size estimate | Variable, often 10+ GB |
| How to change | Chrome → Settings → Downloads → Location → `D:\Data\Downloads` |

### 3.5 Edge Downloads

Same as Chrome — set path to `D:\Data\Downloads`.

### 3.6 Zotero Data Directory

| Item | Details |
|------|---------|
| Default location | `C:\Users\<USER>\Zotero\` |
| Size estimate | 1–30 GB (including PDFs) |
| How to change | Zotero → Edit → Preferences → Advanced → Files and Folders → Data Directory Location |

Change to: `D:\Data\Zotero`

---

## 4. No Change Needed: Small Utilities + System-Level

| Software | Default Location | Size | Why not change |
|----------|------------------|------|----------------|
| Listary | `C:\Users\<USER>\AppData\...` | < 100 MB | Small; config in registry |
| Everything | `C:\Program Files\Everything\` | < 50 MB | Small; index on system drive is faster |
| Snipaste | `C:\Program Files\Snipaste\` | < 100 MB | Small |
| Windows temp files | `C:\Users\<USER>\AppData\Local\Temp\` | < 1 GB | System-level; migration risks issues |
| Browser cache | Inside browser directory | < 1 GB | Small; low migration benefit |
| System logs | `C:\Windows\System32\winevt\` | < 1 GB | System-level; do not touch |

**Handling**: Leave on C:, clean periodically with Storage Sense or manually.

```powershell
# One-click temp cleanup (Administrator)
cleanmgr /sagerun:1
Clear-RecycleBin -Force
```

---

## 5. Environment Variable Reference (Summary)

Copy this table to batch-set environment variables:

| Variable | Recommended Value | Purpose |
|----------|-------------------|---------|
| `PIP_CACHE_DIR` | `D:\Caches\pip` | pip cache |
| `UV_CACHE_DIR` | `D:\Caches\uv` | uv cache |
| `HF_HOME` | `D:\Caches\huggingface` | HuggingFace model cache |
| `TRANSFORMERS_CACHE` | `D:\Caches\huggingface\hub` | transformers legacy variable |
| `NPM_CONFIG_CACHE` | `D:\Caches\npm` | npm cache |
| `NPM_CONFIG_PREFIX` | `D:\Caches\npm\prefix` | npm global install directory |
| `CARGO_HOME` | `D:\Caches\cargo` | Rust Cargo directory |
| `TORCH_HOME` | `D:\Caches\torch` | PyTorch model cache |
| `GOPATH` | `D:\Caches\go` | Go workspace (if using Go) |
| `GOMODCACHE` | `D:\Caches\go\pkg\mod` | Go module cache |

### Batch Setup Script

```powershell
# Run PowerShell as Administrator
$caches = @{
    "PIP_CACHE_DIR"      = "D:\Caches\pip"
    "UV_CACHE_DIR"       = "D:\Caches\uv"
    "HF_HOME"            = "D:\Caches\huggingface"
    "TRANSFORMERS_CACHE" = "D:\Caches\huggingface\hub"
    "NPM_CONFIG_CACHE"   = "D:\Caches\npm"
    "CARGO_HOME"         = "D:\Caches\cargo"
    "TORCH_HOME"         = "D:\Caches\torch"
}

foreach ($k in $caches.Keys) {
    [System.Environment]::SetEnvironmentVariable($k, $caches[$k], "User")
    New-Item -ItemType Directory -Force -Path $caches[$k] | Out-Null
    Write-Host "✅ $k = $($caches[$k])" -ForegroundColor Green
}

# Restart terminal for env vars to take effect
Write-Host "Please restart PowerShell for environment variables to take effect" -ForegroundColor Yellow
```

---

## 6. Junction Approach (For Electron Apps Without Env Var Support)

### 6.1 When to Use Junctions

- Software doesn't support env var redirection
- Software doesn't support launch argument redirection
- But the cache directory is genuinely large

### 6.2 Trae Cache Subdirectories

Trae (Electron-based) generates large caches at:

```
C:\Users\<USER>\AppData\Roaming\Trae\Cache\
C:\Users\<USER>\AppData\Roaming\Trae\CachedData\
C:\Users\<USER>\AppData\Roaming\Trae\Code Cache\
C:\Users\<USER>\AppData\Roaming\Trae\GPUCache\
```

**Junction steps**:

```powershell
# 1. Close Trae
Get-Process Trae -ErrorAction SilentlyContinue | Stop-Process -Force

# 2. Create D: target directory
$target = "D:\Caches\Trae\Cache"
New-Item -ItemType Directory -Force -Path $target | Out-Null

# 3. Backup and remove original directory
$source = "$env:APPDATA\Trae\Cache"
if (Test-Path $source) {
    Rename-Item $source "$source.bak"
}

# 4. Create junction
cmd /c mklink /J "$source" "$target"

# 5. Verify
Get-Item "$source" | Select-Object Name, LinkType, Target

# 6. After Trae starts normally, delete .bak
Remove-Item "$source.bak" -Recurse -Force
```

### 6.3 Generic Template for Other Electron Apps

Applies to: Slack / Discord / Notion / Feishu, etc.

```powershell
function Move-ToD-WithJunction {
    param(
        [string]$SourcePath,
        [string]$TargetPath
    )

    if (-not (Test-Path $SourcePath)) {
        Write-Warning "Source path does not exist: $SourcePath"
        return
    }

    # Create target
    New-Item -ItemType Directory -Force -Path $TargetPath | Out-Null

    # Copy contents
    Copy-Item -Path "$SourcePath\*" -Destination $TargetPath -Recurse -Force

    # Backup original directory
    Rename-Item $SourcePath "$SourcePath.bak"

    # Create junction
    cmd /c mklink /J "$SourcePath" "$TargetPath"

    Write-Host "✅ Junction created: $SourcePath → $TargetPath" -ForegroundColor Green
    Write-Host "Delete .bak directory after verification" -ForegroundColor Yellow
}
```

### 6.4 Junction Caveats

- ⚠️ **Do not junction Program Files binaries** (updates will break)
- ⚠️ **Junctions are directory-level — not for single files**
- ✅ Good for `AppData\Roaming\<App>\Cache` cache subdirectories
- ✅ Deleting a junction does not delete target content (but confirm it's a junction, not a regular directory, before deleting)

---

## 7. Cursor Full Configuration Plan

### 7.1 Shortcut Launch Arguments

```
"C:\Program Files\Cursor\Cursor.exe" --user-data-dir=D:\Dotfiles\Cursor\UserData --extensions-dir=D:\Caches\Cursor\Extensions
```

### 7.2 Pre-create Directories

```powershell
$dirs = @(
    "D:\Dotfiles\Cursor\UserData",
    "D:\Caches\Cursor\Extensions"
)
foreach ($d in $dirs) {
    New-Item -ItemType Directory -Force -Path $d | Out-Null
}
```

### 7.3 Migrate Existing Config (from old PC)

```powershell
# Copy Cursor config backed up from old PC
$oldCursor = "C:\Users\<USER>\AppData\Roaming\Cursor\User"  # Example old location
$newCursor = "D:\Dotfiles\Cursor\UserData\User"

if (Test-Path $oldCursor) {
    Copy-Item -Path $oldCursor -Destination $newCursor -Recurse -Force
    Write-Host "✅ Cursor user config migration complete" -ForegroundColor Green
}
```

### 7.4 Verification

Launch Cursor → Help → About → confirm "User data directory" shows `D:\Dotfiles\Cursor\UserData`.

---

## 8. Migration Checklist

### Must Change

- [ ] conda envs_dirs points to D:
- [ ] `PIP_CACHE_DIR` set
- [ ] `UV_CACHE_DIR` set
- [ ] `HF_HOME` set
- [ ] `NPM_CONFIG_CACHE` set
- [ ] `CARGO_HOME` set (if using Rust)
- [ ] `TORCH_HOME` set
- [ ] Cursor launch arguments configured
- [ ] Trae launch arguments configured

### Should Change

- [ ] WeChat file storage → D:
- [ ] QQ file storage → D:
- [ ] Feishu file storage → D:
- [ ] Chrome downloads → D:
- [ ] Edge downloads → D:
- [ ] Zotero data directory → D:

### No Change Needed

- [ ] Listary / Everything / Snipaste keep defaults
- [ ] Browser cache keeps default (clean periodically)
- [ ] Windows temp files keep default

### Verification

- [ ] C: free space > 50 GB
- [ ] D: has Caches / Data / Dotfiles root directories
- [ ] All environment variables still effective after reboot
