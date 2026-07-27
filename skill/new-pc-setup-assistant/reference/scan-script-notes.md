# Scan script notes

> `scan-old-pc.ps1` is the bundled migration helper for this project.
> Run on the old PC; scans five dimensions and writes a Markdown report for AI planning.

---

## 1. Script location

```
skill/new-pc-setup-assistant/templates/scan-old-pc.ps1
```

---

## 2. Usage

### Prerequisites

- Windows 10 / 11
- PowerShell 5.1+ (PowerShell 7 recommended)
- Administrator (some scans need it; run elevated when possible)

### Run

```powershell
# 1. Open PowerShell as Administrator
# 2. Go to script directory
cd D:\new-pc-setup-playbook\skill\new-pc-setup-assistant\templates

# 3. Bypass execution policy (current session only)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# 4. Run scan
.\scan-old-pc.ps1

# 5. Open report (same directory as script)
notepad ".\old-pc-scan-report.md"
```

### Parameters

This script **accepts no parameters**. Defaults are hard-coded:

| Item | Default | Notes |
|------|---------|-------|
| Output path | `$PSScriptRoot\old-pc-scan-report.md` | Same folder as script |
| Software lookback | 90 days | Recently used apps |
| Cache threshold | 500 MB | Folders larger than this |
| Repo scan depth | 4 levels | From each root |
| Upload | Never | Local report only |

---

## 3. Five scan dimensions

| # | Dimension | Source | Purpose |
|---|-----------|--------|---------|
| 1 | Software usage | UserAssist registry | Keep/cut decisions |
| 2 | Cache layout | AppData scan | Cache migration list |
| 3 | Environment | Installed tools | Replicate dev stack |
| 4 | Git repos | `.git` under common paths | Project migration list |
| 5 | SSH config | `~/.ssh/` metadata | SSH replication checklist |

---

## 4. Report format

### 4.1 Structure

Markdown report with five sections:

```markdown
# Old PC scan report

**Scan time**: 2026-07-20 10:00:00
**Username**: [USER] (redacted)
**Operating system**: Microsoft Windows NT 10.0.22631.0

## 1. Software usage (last 90 days)
| Application | Last used | Run count | Path |
|-------------|-----------|-----------|------|

## 2. Cache layout (> 500MB folders)
### AppData\Local
| Folder | Size (MB) |
|--------|-----------|

## 3. Environment
### conda / Python / CUDA / Node.js / Git / LaTeX / MATLAB

## 4. Git repositories (.git folders)
| Repository path | Remote URL |
|-----------------|------------|

## 5. SSH configuration
| File name | Present |
|-----------|---------|
```

### 4.2 Field meanings

**Dimension 1: Software usage**

| Field | Meaning |
|-------|---------|
| Application | Executable name (e.g. Cursor.exe) |
| Last used | Most recent launch time |
| Run count | Total launches (UserAssist) |
| Path | Full path (username → `[USER]`) |

**Dimension 2: Cache layout**

Scans `AppData\Local`, `AppData\Roaming`, and `AppData\LocalLow`; lists subfolders > 500 MB with size in MB.

**Dimension 3: Environment**

Detects:

| Tool | Detection |
|------|-----------|
| conda | Common install paths |
| Python | `python` on PATH |
| CUDA | First 15 lines of `nvidia-smi` |
| Node.js / npm | `node` / `npm` on PATH |
| Git | `git` on PATH + global user.name (redacted) |
| LaTeX | MiKTeX / TeX Live paths |
| MATLAB | Common install paths |

**Dimension 4: Git repositories**

Scans (depth 4):
- `D:\`
- `%USERPROFILE%\Desktop`
- `%USERPROFILE%\Documents`

Outputs local path and first line of `git remote -v`.

**Dimension 5: SSH**

Checks **file existence** under `~/.ssh/` only — **no file contents** (privacy).

---

## 5. Privacy (important)

### 5.1 No upload

- Script **never uploads** data
- Results **only** in local Markdown report

### 5.2 No key contents

| File type | Handling |
|-----------|----------|
| `~/.ssh/id_*` (private keys) | ❌ existence only |
| `~/.ssh/id_*.pub` | ❌ existence only |
| `~/.ssh/config` | ❌ existence only |
| `~/.ssh/known_hosts` | ❌ existence only |
| `.env` | ❌ not scanned |
| `*credential*` / `*token*` / `*secret*` | ❌ not scanned |

### 5.3 Username redaction

Paths replace username with `[USER]`:

- Original: `C:\Users\<yourname>\AppData\Local\...`
- Report: `C:\Users\[USER]\AppData\Local\...`

### 5.4 Hostname

Report header omits hostname; only OS version string.

### 5.5 Git remotes

Section 4 may include GitHub usernames in remote URLs. Review `## 4. Git repositories` before sharing.

---

## 6. Using the report for migration planning

### 6.1 AI workflow

Give `old-pc-scan-report.md` to the brain AI; apply Node 4 rules in `decision-flow.md`:

```
1. Read section 1 (software usage); apply three-layer rules
2. Read section 2 (cache); map to must-change / should-change / leave-default lists
3. Read section 3 (environment); build replication checklist
4. Read section 4 (repos); build project migration list
5. Read section 5 (SSH); build SSH replication steps
6. Output migration plan
```

### 6.2 Prompt example

Paste to Cursor / Trae:

```
Read .\old-pc-scan-report.md and produce a migration plan.

References:
- 02-decision-frameworks\software-keep-cut-matrix.md
- 02-decision-frameworks\cache-migration-decision-table.md
- skill\new-pc-setup-assistant\reference\decision-flow.md

Output:
1. Software keep/cut table
2. Cache migration table
3. Environment checklist
4. Repository migration list
5. SSH replication steps
6. Execution order and estimated time
```

### 6.3 Interpretation examples

#### Software (excerpt)

| App | Last used | Decision | Notes |
|-----|-----------|----------|-------|
| Cursor.exe | 2026-07-19 | Migrate → Foundation | User data on D: |
| Docker Desktop.exe | 2026-03-12 | Defer | Install when needed |
| Slack.exe | 2025-12-01 | Cut | Replaced by Feishu |

#### Cache (excerpt)

| App | Current size | Decision | Method |
|-----|--------------|----------|--------|
| conda envs | 32.5 GB | Must change | `.condarc` |
| HF cache | 87 GB | Must change | `HF_HOME` |
| pip cache | 3.2 GB | Must change | `PIP_CACHE_DIR` |
| WeChat files | 12.8 GB | Should change | WeChat settings |

### 6.4 Edge cases

#### Empty section

If a dimension failed (e.g. permissions), the section may be empty or say "not detected". Prompt user:

```
⚠️ Cache section is empty — possible cause: insufficient permissions.
Re-run scan-old-pc.ps1 as Administrator.
```

#### Stale report

If scan time is > 30 days ago:

```
⚠️ Report is 60 days old; usage may have changed.
Re-run scan-old-pc.ps1 for fresh data.
```

---

## 7. Developer notes

### 7.1 Dependencies

- No third-party deps; PowerShell built-ins only
- PowerShell 5.1 and 7 compatible

### 7.2 UserAssist decoding

UserAssist values use ROT13; script decodes inline:

```powershell
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
```

### 7.3 Performance

- 100+ apps: ~30–60 seconds
- Cache size scan: ~1–3 minutes (depends on disk)

### 7.4 Extending

Add a new block and append to `$report`:

```powershell
# ============================================================
# 6. New dimension
# ============================================================
Write-Host "[6/6] Scanning new dimension..." -ForegroundColor Yellow
$report += "## 6. New dimension`n`n"
# ... scan logic ...
$report += "`n"
```

---

## 8. Checklist

- [ ] Script downloaded locally
- [ ] PowerShell run as Administrator
- [ ] Execution policy bypassed for session
- [ ] Scan completed without errors
- [ ] `old-pc-scan-report.md` generated
- [ ] Username redacted to `[USER]`
- [ ] No hostname leak
- [ ] Section 4 remotes reviewed for sensitive URLs
- [ ] Report given to AI for migration plan
