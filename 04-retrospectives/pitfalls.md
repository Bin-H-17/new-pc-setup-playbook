# Pitfalls Log

> This document records 10 real pitfalls hit while iterating on the "New PC Setup Playbook." Each entry uses **symptom / cause / correct approach / lesson** so future readers do not repeat them.

---

## Pitfall 1: Wrong CUDA Version (The Most Critical)

### Symptom
The original plan said "RTX 5060 with CUDA 12.4 + PyTorch 2.5." After install, `python -c "import torch; print(torch.cuda.is_available())"` returned `True`, seemingly fine—but `torch.compile` or some fused kernels crashed with `no kernel image is available for execution on the device`.

### Cause
RTX 5060 is **Blackwell architecture, compute capability = sm_120**. PyTorch official wheels for CUDA 12.4 **do not include kernels compiled for sm_120**. Earliest sm_120 support appears in **CUDA 12.8 + PyTorch 2.9+** wheels. `is_available()` True only means the driver sees the GPU—not that PyTorch-built kernels can run on it.

### Correct approach
```
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128
```
After install, validate with this 6-step script:
```
nvidia-smi
python -c "import torch; print(torch.cuda.is_available())"
python -c "import torch; print(torch.cuda.get_device_name(0))"
python -c "import torch; print(torch.cuda.get_device_capability())"   # expect (12, 0)
python -c "import torch; print(torch.__version__)"                    # expect 2.9+
python -c "import torch; @torch.compile; def f(x): return x+1; print(f(torch.ones(3)))"
```

### Lesson
**"Can import" ≠ "can use."** CUDA compatibility is not proven until `get_device_capability` + `torch.compile` pass. Opus found this alone in round 3; GPT and Grok missed it in rounds 1–2—multi-model review does fill blind spots.

---

## Pitfall 2: Wrong Driver Install Order

### Symptom
New PC in hand; habit was run Windows Update first, then install latest NVIDIA driver from the site. NVIDIA installer reported "a newer version already exists," but `nvidia-smi` showed the old driver Windows Update installed; CUDA 12.8 would not install.

### Cause
Windows Update pushes a WHQL NVIDIA driver that is usually 2–3 months behind the site and **claims the driver signature slot**. Installing the site driver afterward, the system thinks a driver exists—the installer may skip or roll back.

### Correct approach
Strict driver install order:
1. **OEM support tools** (e.g. HP Support Assistant / Lenovo Vantage / Dell SupportAssist) for BIOS / chipset / NIC firmware.
2. **NVIDIA site**: download and install latest Studio Driver (AI research: Studio over Game Ready for stability).
3. **Windows Update last**; before running, in Advanced options → Optional updates **uncheck NVIDIA driver** to avoid overwrite.
4. After Windows Update, run `nvidia-smi` again to confirm the driver was not rolled back.

### Lesson
**OEM tools → vendor site → Windows Update** applies to any device with dedicated drivers (GPU / touchpad / fingerprint reader). Windows Update always last; actively exclude dedicated drivers.

---

## Pitfall 3: Cursor Parameter Semantics Confusion

### Symptom
Original plan used:
```
cursor --user-data-dir=D:\CursorCache --extensions-dir=D:\CursorCache\ext
```
Intent was move "cache" to D:. Result: settings.json / keybindings.json / snippets landed in the so-called cache dir; reinstall almost lost config.

### Cause
**`--user-data-dir` is not cache; it is user data.** It holds:
- `settings.json` (user settings)
- `keybindings.json` (shortcuts)
- `snippets/` (code snippets)
- `keymap/`, `workspaceStorage/`, etc.

These **belong in Dotfiles backup**, not disposable cache. True disposable cache is extensions via `--extensions-dir`.

### Correct approach
```
cursor --user-data-dir=D:\Dotfiles\Cursor --extensions-dir=D:\Cache\Cursor\ext
```
- `--user-data-dir` → **Dotfiles backup** (git-managed).
- `--extensions-dir` → **cache** (safe to delete and reinstall).
- Add `install.ps1` in the Dotfiles repo to symlink config back on a new PC.

### Lesson
**Parameter name ≠ semantics.** Treating anything with "data" as throwaway cache is wrong. For Cursor / VS Code family flags, check official docs for what each path holds, then decide Dotfiles vs Cache.

---

## Pitfall 4: Junctioning Entire User Data Dir Breaks Electron Updates

### Symptom
To keep Trae Work off C:, entire `%APPDATA%\Trae Work` was `mklink /J` to D:. Daily use fine; Trae Work auto-update failed with `Update failed: signature verification`, repeated prompts.

### Cause
Electron auto-update verifies package signature + target paths. When the whole user data dir is a junction:
- Updater writes temp files on physical path but reads logical path—**path comparison fails**.
- Some Electron apps (VS Code, Trae Work, WeChat DevTools) **explicitly detect junction / symlink** and refuse update.

### Correct approach
**Junction only Cache subdirs, not the whole user data dir.** For Trae Work:
- Keep `%APPDATA%\Trae Work` on C:; **do not junction** the root.
- Junction only `%APPDATA%\Trae Work\Cache`, `Code Cache`, `GPUCache`—clear cache subdirs—to D:.
- Credential files (e.g. `.trae-cn`, `.codex`) **never junction**—see Pitfall 6.

### Lesson
**Junction is surgery, not a whole-house move.** Prefer small cache subdir junctions over whole app dirs. Per Electron app, map structure: cache vs config vs credentials.

---

## Pitfall 5: Dual conda Install Wastes ~20GB

### Symptom
Old PC had `anaconda3` (~20GB, Navigator + preinstalled packages) and `miniconda3` (empty shell for envs). Two separate pkgs caches on C: and D:; env paths often confused.

### Cause
anaconda3 installed for Navigator GUI; research ended up CLI-only. miniconda3 added because anaconda3 base was polluted by preinstalls. Both stayed installed.

### Correct approach
New PC: **miniconda3 only**, path `D:\conda`.
- Need GUI: install `anaconda-navigator` package only, not full anaconda3.
- Manage envs declaratively via `environment.yml`.
- `conda config --set pkgs_dirs D:\conda\pkgs` for D: pkgs cache.

### Lesson
**GUI ≠ productivity.** anaconda3 "bundle" is often negative ROI in research—200+ preinstalled packages, ~90% unused, pollutes base. Always start miniconda3; add packages on demand.

---

## Pitfall 6: Junctioning `.trae-cn` / `.codex` Too

### Symptom
To "fully clean C:", `.trae-cn` and `.codex` were junctioned to D:. After a Trae upgrade, login state lost, re-scan QR; after Codex CLI update, credentials invalid, rerun `codex auth`.

### Cause
1. **Credential security**: `.trae-cn`, `.codex` hold OAuth tokens / API keys—**keep default C: user profile**, not D:. D: may be shared, cloud-backed, or read by other tools—higher exposure.
2. **Frequent updates**: Trae and Codex rewrite credential dirs on update; junction writes can race (especially write + rename), corrupting credential files.

### Correct approach
- `.trae-cn`, `.codex`, `.aws`, `.ssh`, `.gnupg` and **all credential dirs stay on C: default locations**.
- Junction only explicit cache/data subdirs (e.g. `.trae-cn\cache`, `.codex\logs`).
- Back up credentials via encrypted channels (1Password / Bitwarden), not filesystem junction.

### Lesson
**Credential dirs are off limits.** Any dot-dir with tokens / keys / certs: no junction; a few MB on C: is fine. Security > disk space.

---

## Pitfall 7: Full AppData Migration Rejected

### Symptom
Initial plan junctioned all of `%APPDATA%` and `%LOCALAPPDATA%` to D: to free C:. All three AIs rejected it with concrete crash scenarios.

### Cause
1. **Hard-coded absolute paths**: Some Electron / UWP apps store `C:\Users\<user>\AppData\Roaming\<app>\config.json`; after junction, logic still points at C: but files live on D:—**sometimes works, sometimes errors** (Win32 vs .NET API).
2. **ACL inheritance**: AppData ACLs inherit from `C:\Users\<user>`; junction to D: keeps C: ACLs while D: root ACL differs—some security tools flag "permission anomaly."
3. **Windows sandbox / UWP**: AppContainer support for junctions is inconsistent; some UWP refuses junctioned paths.

### Correct approach
**No bulk migration.** Use "junction per app Cache subdir on demand":
- Only **confirmed safe** apps (VS Code, Cursor, Trae Work, Chrome): junction Cache / GPUCache / Code Cache subdirs.
- Credential and config dirs stay on C:.
- Before each junction, inspect app dir structure: cache / config / credentials.

### Lesson
**Bulk migration is a trap.** Looks like one-shot fix; risks explode together. Per-app, per-subdir migration is slower but each decision is reversible and debuggable.

---

## Pitfall 8: Trae Cache ~16GB on C:

### Symptom
After one week on new PC, C: free space dropped from ~80GB to ~60GB. `%APPDATA%\Trae Work` alone was ~16GB: `Cache`, `Code Cache`, `GPUCache`, `Service Worker\Cache`, `CachedData`, etc.

### Cause
Trae Work is Electron + VS Code core; caches:
- File search index
- LSP cache
- GPU shader cache
- Extension host cache
- Web content (Service Worker, HTTP cache)

Defaults on C:; grows roughly linearly with use.

### Correct approach
Junction subdirs one by one; **do not junction all of `%APPDATA%\Trae Work`**:
```powershell
$trae = "$env:APPDATA\Trae Work"
$dst  = "D:\Cache\TraeWork"
foreach ($sub in @("Cache","Code Cache","GPUCache","CachedData","Service Worker")) {
    Move-Item "$trae\$sub" "$dst\$sub" -Force
    New-Item -ItemType Junction -Path "$trae\$sub" -Target "$dst\$sub"
}
```
Close Trae Work before running; reopen and verify recent projects load.

### Lesson
**Electron app cache is a C: black hole.** Any Electron app can grow to several GB in AppData. First week after install, check AppData size and junction cache subdirs early.

---

## Pitfall 9: WeChat File Path "Hard to Change"

### Symptom
Plan said "WeChat chat file path is hard to change; keep default." Actually **you can change it**: WeChat PC Settings → File Management → Change moves chat files to D:. After change, old chat images/files still read from old C: paths—incomplete migration.

### Cause
1. **New files use new path**: After setting change, new files go to D:.
2. **Old files stay on C:**: Pre-change history remains at `C:\Users\<user>\Documents\WeChat Files\<openid>\`; WeChat does not auto-migrate.
3. **DB index not updated**: MSG DB stores absolute paths; changing settings **does not rewrite old paths**—old chat images still look on C:.

### Correct approach
- **First WeChat install on new PC**: set file path to D: immediately (e.g. `D:\WeChat\<openid>`).
- **Old PC migration**: manually `Move-Item` entire `WeChat Files\<openid>\` to D:, then point settings at new path. **Old image paths in chat won't auto-update**—not practical to fix one by one. Acceptable: leave old images in C: backup image only.
- **Critical data**: chat text in MSG0.db etc. must migrate; images/video if too costly can be dropped if already backed up.

### Lesson
**"Path can change" ≠ "history migrates."** Path change affects new data only; old data move manually or abandon. On any app with local storage, **first task after install: change default storage path**.

---

## Pitfall 10: Missing uv Cache Config

### Symptom
Plan set `PIP_CACHE_DIR=D:\Cache\pip`; assumed pip cache was on D:. Later `uv pip install` still wrote to `C:\Users\<user>\AppData\Local\uv\cache`; C: lost several more GB.

### Cause
**uv ignores `PIP_CACHE_DIR`; it uses `UV_CACHE_DIR`.** pip and uv are separate cache systems:
- pip → `PIP_CACHE_DIR`
- uv → `UV_CACHE_DIR`
- poetry → `POETRY_CACHE_DIR`
- pdm → `PDM_CACHE_DIR`

Configuring one leaves others on C:.

### Correct approach
Set all Python package manager cache paths at once:
```powershell
[Environment]::SetEnvironmentVariable("PIP_CACHE_DIR", "D:\Cache\pip", "User")
[Environment]::SetEnvironmentVariable("UV_CACHE_DIR",   "D:\Cache\uv",   "User")
[Environment]::SetEnvironmentVariable("POETRY_CACHE_DIR","D:\Cache\poetry","User")
[Environment]::SetEnvironmentVariable("PDM_CACHE_DIR",  "D:\Cache\pdm",  "User")
# conda pkgs cache
conda config --set pkgs_dirs D:\conda\pkgs
# npm cache
npm config set cache D:\Cache\npm
```
Put these in `setup-env.ps1` for one-shot run.

### Lesson
**Each package manager has its own cache variable.** Migration checklists can't assume "pip is enough"—list every tool in use and look up its cache env var. Same for npm / yarn / pnpm / bun / cargo / go mod / gradle / maven, etc.

---

## Pitfalls Overview Table

| # | Pitfall | Severity | Found by |
|---|---------|----------|----------|
| 1 | CUDA 12.4 → 12.8 | ★★★★★ | Round 3 Opus review |
| 2 | Driver install order | ★★★★ | Self + retrospective |
| 3 | Cursor `--user-data-dir` semantics | ★★★ | Round 5 detail review |
| 4 | Junction whole user dir | ★★★★ | Self + Electron docs |
| 5 | Dual conda install | ★★ | Old PC scan |
| 6 | Credential dir junction | ★★★★★ | Self + security review |
| 7 | Full AppData migration | ★★★★ | Round 1 three-model consensus |
| 8 | Trae ~16GB cache | ★★★ | Self |
| 9 | WeChat file path | ★★ | Self |
| 10 | Missing uv cache config | ★★★ | Round 5 detail review |

---

## Reuse Recommendations

1. **Any new PC setup plan needs at least 3 AI review rounds**: concept / technical / detail. Technical layer hides "can import but can't use" bugs most often.
2. **Junction only Cache subdirs—not whole app dirs, not credential dirs.**
3. **Configure cache env var per package manager / toolchain** in one `setup-env.ps1`.
4. **Driver order: OEM tools → vendor site → Windows Update (exclude dedicated drivers).**
5. **First week after new app install, check AppData size** and junction cache subdirs early.
