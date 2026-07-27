# Plan B Strategy: Install Apps on C: or D: on a New PC

## 1. The Problem

On a new PC, C: is usually a ~160 GB SSD and D: is a larger HDD or second SSD. Every installer asks the same question: **where to install?**

Two traditional answers:

- **Conservative**: Default to C:, keep it simple
- **Aggressive**: Install on D: to avoid filling C:

Both have problems:

- **Conservative**: C: fills up quickly; app data and cache pile on C:; red bar within six months
- **Aggressive**: Manual path selection for every app; some apps have compatibility issues on D: (Chinese paths, permissions, registry quirks)

The real confusion is treating **the application binary** and **data/cache produced by the app** as one thing. They differ by an order of magnitude in size and in migration difficulty. Plan B separates the two.

## 2. Plan A (Traditional Aggressive Approach)

**Approach**: App binaries on D: + cache on D:

**Pros**:
- C: barely grows
- All data on D:; backup/migration focuses on D: only

**Cons**:
- Every install needs manual path selection—double the configuration work
- Some apps misbehave on D: (especially domestic apps, games, certain Adobe components)
- Paths with Chinese characters or spaces cause odd behavior in some apps
- Upgrades that forget D: reinstall to C:, leaving duplicates
- "Installed on D:" often only moves the main binary; cache/AppData still writes to C:—you thought you fixed it, C: still grows

**Real experience**: High effort, unstable payoff. A week later C: is still growing because many caches cannot be redirected.

## 3. Plan B (Recommended)

**Approach**: App binaries on C: (default locations) + all data/cache on D:

**Core observation**:
- **App binaries are small**—most apps are a few hundred MB each; total ~6 GB
- **Space hogs are data/cache**—conda envs 20–30 GB, HuggingFace cache tens of GB, browser cache several GB, WeChat files tens of GB… these blow up C:

Split the two:
- Binaries on C: defaults—simple, compatible, ~6 GB fits easily
- Data/cache via env vars/Junction/app settings on D:—C: stays healthy

### C: Space Estimate

Example: 160 GB C:

| Item | Size |
|---|---|
| Windows system | ~50 GB |
| App binaries (all default installs) | ~6 GB |
| System temp + browser cache | ~3–5 GB |
| **Total** | **~60 GB** |
| **Remaining** | **~100 GB** |

Plenty of headroom. Even with large suites (Office, Adobe), ~100 GB free is enough.

### Exceptions

Two categories **must** live on D:, not C:

| Item | Reason | Size |
|---|---|---|
| conda environments | Single env can be several GB; multiple envs stack to 20–30 GB | 20–30 GB |
| Docker / WSL2 images | Container images are GB-scale and keep growing | Variable |
| HuggingFace cache | Model files tens of GB | Tens of GB |
| pip cache | Many packages → several GB | Several GB |

These are not "app binaries"; they are data/cache and belong on D: under Plan B anyway.

## 4. Three Categories for User Data

Moving data to D: is not one-size-fits-all. Two dimensions—**volume** and **can it be redirected?**—yield three categories:

### 1. Must Change (Dev Tools: Large + Redirectable)

Large (GB to tens of GB) with clear configuration hooks (env vars, config files, CLI flags). **If unchanged, C: will fill.**

| Item | How |
|---|---|
| Cursor user data | Launch arg `--user-data-dir=D:\Dotfiles\Cursor` |
| Cursor extensions | Launch arg `--extensions-dir=D:\Caches\Cursor\extensions` |
| conda environments | `conda config --add envs_dirs D:\conda\envs` |
| pip cache | Env var `PIP_CACHE_DIR=D:\Caches\pip` |
| HuggingFace cache | Env var `HF_HOME=D:\Caches\huggingface` |
| npm cache | `npm config set cache D:\Caches\npm` |
| Trae Cache subdirectory | Junction: `mklink /J "C:\Users\xxx\AppData\...Cache" "D:\Caches\Trae\Cache"` |

### 2. Recommended (Social Apps: Large + App Settings)

Also large (WeChat/QQ files often tens of GB), but configured in app settings—not env vars—one-time manual change.

| Item | How |
|---|---|
| WeChat file storage | WeChat Settings → File Management → `D:\WeChat` |
| QQ file storage | QQ Settings → File Management → `D:\QQ` |
| Feishu file storage | Feishu Settings → File Storage → `D:\Feishu` |
| Chrome downloads | Chrome Settings → Downloads → `D:\Downloads` |
| Edge downloads | Edge Settings → Downloads → `D:\Downloads` |
| Zotero data directory | Zotero Settings → Advanced → Data directory → `D:\Zotero` |

Why "recommended" not "must"? Low social-app usage may stay small on C:. Still recommended—cache growth is unpredictable (who knows what lands in group chat tomorrow).

### 3. Leave Alone (Small Tools + System: Small + Hard to Change)

Small (MB to low hundreds of MB), awkward to move (registry, system settings, side effects). **Benefit < cost**—leave on C:.

| Item | Why leave on C: |
|---|---|
| Listary / Everything / Snipaste | Config is a few MB; moving paths touches registry |
| Windows temp (`%TEMP%`) | System-level; changing affects some app behavior |
| Browser cache (non-download) | Chrome/Edge cache lives under user-data-dir; follows Cursor/Edge user data—no separate change |
| System logs | MB-scale; system-managed—do not touch |
| Windows Defender definition files | System-level; not user-configurable |

Combined, these grow less than ~1 GB per year—not worth the effort.

## 5. Cursor Configuration Correction

Cursor is a common footgun—called out separately.

### Wrong Configuration

Many people write:
```
--user-data-dir=D:\Caches\Cursor
--extensions-dir=D:\Caches\Cursor\extensions
```

Both under Caches. **That is wrong.**

### Correct Configuration

```
--user-data-dir=D:\Dotfiles\Cursor
--extensions-dir=D:\Caches\Cursor\extensions
```

### Why

`--user-data-dir` and `--extensions-dir` mean different things:

| Argument | Contents | Nature | Where |
|---|---|---|---|
| `--user-data-dir` | settings.json / keybindings.json / snippets / workspace state | **Back up** | Dotfiles (version control) |
| `--extensions-dir` | Extension binaries (extracted VSIX) | **Disposable** | Caches (reinstall restores) |

Consequences of swapping them:
- User data in Caches: you won't back up Caches → **all Cursor config lost on reinstall**
- Extensions in Dotfiles: version-controlled repo polluted with tens of MB of binaries

Split correctly: Dotfiles → git commits; Caches → discard freely, reinstall restores.

### General "Dotfiles vs Caches" Split

Applies to all AI tools and editors:

| Type | Contents | Location | Backup |
|---|---|---|---|
| Dotfiles | Config, keybindings, snippets, templates | `D:\Dotfiles\` | git + cloud backup |
| Caches | Extensions, cache, indexes, logs | `D:\Caches\` | No backup; reinstall restores |
| Data | Real data (notes, code, docs) | `D:\Workspace\` etc. | Separate backup policy |

Separating "must back up" from "disposable" is key to Plan B staying low-maintenance.

## 6. Junctions for Large Cache Folders

Some cache paths **cannot** be changed via env vars or app settings—they are hardcoded under `%LOCALAPPDATA%\<App>\Cache`. Use Windows Junction (directory reparse point).

### How Junction Works

Junction is NTFS directory linking (directories only). C: path points at D: real folder; the app thinks it writes to C:, data lands on D:.

### Example

Trae Cache subdirectory:

```powershell
# 1. Close Trae
# 2. Move C: Cache folder to D:
Move-Item "C:\Users\<username>\AppData\Roaming\Trae\Cache" "D:\Caches\Trae\Cache"
# 3. Create Junction so C: path points to D:
cmd /c mklink /J "C:\Users\<username>\AppData\Roaming\Trae\Cache" "D:\Caches\Trae\Cache"
```

Next launch, the app writes to the C: path; data goes to D:.

### Junction Notes

1. **Use `mklink /J` (Junction)**, not `mklink /D` (Symbolic Link). `mklink /J` does not require admin for the link itself and is transparent to apps; symbolic links need admin and some apps ignore them. (Note: this repo's `Junction-migration-template.ps1` declares `#Requires -RunAsAdministrator` at the top because of system-level copy/delete operations—that is separate from Junction's own permission requirements.)
2. **Close the app before moving** the original folder—locked files block the move.
3. **Avoid nested Junction targets**—can cause recursion issues.
4. **Junctions break on OS reinstall**—recreate after reinstall. Record which directories use Junctions in progress.md.

## 7. Why Plan B Works

### 1. Low Friction

All apps default-install to C:—no per-installer path picking. Roughly half the install workload of Plan A.

### 2. Better Compatibility

Default paths avoid "D: drive + Chinese path / permissions / registry" issues common with domestic and legacy apps.

### 3. C: Does Not Blow Up

Space hogs (data/cache) live on D:. C: holds binaries (~6 GB) + system (~50 GB)—stable free space long term.

### 4. Same Total Config Work as Plan A

Plan A: change path at install time. Plan B: change data/cache paths after install. **Total effort is similar**, but Plan B changes are structured (env vars / app settings / Junction); Plan A changes are ad hoc per installer UI.

### 5. Clear Backup Policy

With Dotfiles / Caches / Data layout:
- Dotfiles: git
- Caches: no backup
- Data: per-type backup

Plan A mixes apps and data on D:—hard to know what to back up.

## 8. Implementation Checklist

Standard Plan B flow for a new PC:

```markdown
## Day 1 (True Foundation)
- [ ] Confirm disk layout (C: 160 GB / D: remainder)
- [ ] Create D: structure: Dotfiles / Caches / Workspace / conda / migration
- [ ] Set env vars: PIP_CACHE_DIR / HF_HOME / npm cache
- [ ] Point conda envs_dirs to D:\conda\envs
- [ ] Install NVIDIA driver + CUDA 12.8
- [ ] Install Git; configure user.name / user.email / SSH keys

## Day 2 (AI Tools)
- [ ] Install Cursor; --user-data-dir → Dotfiles, --extensions-dir → Caches
- [ ] Install Trae; Junction Cache subdirectory to D:
- [ ] Install Codex; configure API key
- [ ] Write AGENTS.md (three-layer classification + progressive disclosure rules)

## Day 3 (Data Migration)
- [ ] WeChat/QQ/Feishu file storage → D:
- [ ] Chrome/Edge downloads → D:\Downloads
- [ ] Zotero data directory → D:\Zotero
- [ ] Confirm HuggingFace cache env var active

## Later (Install As Needed)
- [ ] Docker/WSL2 (when needed; must live on D:)
- [ ] Syncthing (when second machine arrives)
- [ ] mem0 (after AI workflows stabilize)
```

## 9. Summary

Plan B in one line: **binaries are small—C: defaults are easiest; data/cache are large—must go to D: with structured redirects**.

That turns "C: or D:?" into one rule: **apps on C:, data on D:**. You don't memorize per-app quirks—only classify **app vs data**, which works for every tool.

The more "turn anxiety into principle" decisions you make in new PC setup, the more week-one energy stays for truly irreversible foundation choices.
