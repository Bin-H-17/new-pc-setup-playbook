---
name: new-pc-setup-assistant
description: >-
  Plan and migrate a new Windows PC/workstation with AI: three-layer software
  priority, Plan B disk strategy with Junctions, old-PC scan, and staged setup
  guides. Use when the user mentions PC setup, new PC, workstation setup,
  migrate PC, Windows environment migration, or 换电脑 / 新电脑 / 装机. Local-only
  scripts; no telemetry.
---

# New PC Setup Assistant

## Trigger conditions

Activate this skill when the user expresses intent such as:
- "PC setup" / "new PC" / "setup workstation" / "migrate PC"
- "Windows environment migration" / "software migration" / "data migration"
- Optional Chinese triggers: 换电脑 / 新电脑 / 装机辅助 / 电脑配置 / 工作站搭建 / 开发环境配置 / 迁移电脑

## Skill positioning

This skill is an **AI-driven new-PC setup methodology plus automation toolchain**, guiding the user from "blank machine" to "AI takes over configuration" end to end.

Core principles:
1. **Three-layer taxonomy**: Foundation (hard to undo) / Fit-out (adjustable) / Defer (install when needed)
2. **Plan B strategy**: Apps on default system paths; data and caches on the data drive
3. **Progressive disclosure**: Planner AI (brain) vs executor AI (hands)
4. **Multi-model review**: Have multiple AI models review the plan and iterate

## Target users

- Research / academic users (math, AI, data science, robotics, etc.)
- Developers / engineers (Windows users who need dev environments)
- Students (grad / international students building long-term workstations)
- Heavy AI tool users (Cursor / Trae / Codex / Obsidian, etc.)

## Execution flow

### Phase 0: Requirements gathering (AI asks proactively)

After trigger, ask the user (one-by-one or in batches, flexibly):

**Required**:
1. New PC SSD capacity? (e.g. 512GB / 1TB / 2TB)
2. GPU model? (e.g. RTX 4060 / 5060 / 4090 / iGPU / no dGPU)
3. Field / role? (research / dev / design / gaming — drives environment choices)
4. Old PC to migrate from?
5. Primary use cases? (deep learning / math modeling / web dev / data analysis / reference management)
6. Budget / time preference? ("full setup day one" vs "install as you go")

**Optional** (better if known):
7. conda / Python?
8. LaTeX?
9. Obsidian / Notion or similar?
10. WSL2 / Docker?
11. Cursor / Trae / Codex?
12. Remote sync / dual-machine workflow?

**Privacy**: Do not ask for real name, school, employer, API keys, etc. Use redacted placeholders (e.g. `[USER]`, not real usernames).

### Phase 1: Old-PC scan (if user has old PC and agrees)

Ask: "May I scan your old PC for software usage, cache layout, and environment config? Results are used only for migration advice; nothing is uploaded."

**After consent, run** `templates/scan-old-pc.ps1`:

Scan covers:
1. **Software usage**: UserAssist registry, last 30/90 days
2. **Cache layout**: AppData\Local and Roaming folders > 500MB
3. **Environment**: conda, Python, CUDA, Node.js, Git, etc.
4. **Git repos**: `.git` under D:\, Desktop, Documents
5. **SSH**: `.ssh\config` presence only (no key contents)

Report output: `old-pc-scan-report.md`

**Privacy**:
- Script never uploads data
- Report keeps app names and paths; no personal file contents
- SSH key contents not read; existence only
- Browser passwords / cookies not scanned

### Phase 2: Plan generation

From Phase 0 and 1, produce:

#### 2.1 Partition plan
- Recommend partitions from SSD size (see repo `02-decision-frameworks/` and this skill's `reference/decision-flow.md`)
- Volume label suggestions

#### 2.2 Software keep/cut list
- Three-layer taxonomy from scan:
  - **Foundation**: day-one (partitions / drivers / dev stack / Git / SSH)
  - **Fit-out**: after foundation (Obsidian / AI tools / LaTeX / browser)
  - **Defer**: install when needed (Docker / WSL2 / Syncthing / niche tools)
- Per old-PC app: migrate / cut / defer

#### 2.3 Environment plan
By field:
- **Research / AI**: conda (med / pde / math, etc.) + PyTorch + CUDA
- **Dev**: Node.js + Python + Git
- **Math**: LaTeX (MiKTeX / TeX Live) + Python + MATLAB (if any)
- **General**: Python + Git + editor

#### 2.4 Cache migration plan
- Which caches move to data drive
- Which use Junctions
- Which stay default

#### 2.5 AI tool roles
- Brain (Cursor / Trae): plan + decide + supervise
- Executor (Trae / Codex): scripts + installs + unpack
- Automation (Codex / Task Scheduler): scheduled jobs

### Phase 3: Deliverables

Two zip bundles:

#### Zip 1: `migration-bundle.zip` (user copies to new PC)
- `obsidian-vault.zip` (if Obsidian + old vault)
- `trae-skills.zip` (if Trae + skill assets)
- `ssh-config.zip` (if SSH config)
- `browser-data.zip` (bookmarks / history / prefs; no passwords)
- `apps-config.zip` (other app config backups)

#### Zip 2: `plan-bundle.zip` (extract to data drive on new PC)
- `00_AI-startup-guide.md` (main entry for AI)
- `01_action-checklist.md` (manual + automated steps)
- `02_software-download-list.md` (name + download + install path)
- `03_environment-setup.md` (conda / Python / CUDA, etc.)
- `04_folder-layout.md` (tree + setup-env.ps1 + Junction plan)
- `05_open-decisions.md` (user sign-off items)
- `setup-env.ps1`
- `scan-old-pc.ps1` (backup copy)
- `progress.md` (progress log template)

### Phase 4: User manual checklist

Steps AI cannot do:
1. First boot + local account (skip online account if desired)
2. Disk partitioning
3. Drivers (OEM tool → NVIDIA → Windows Update)
4. System trim (hibernation / page file / power plan)
5. Remove bloatware
6. Install scout IDEs (Cursor / Trae)
7. IDE shortcut flags
8. Copy migration bundle to new PC

### Phase 5: AI takeover

After manual steps, start AI (Cursor / Trae); read `00_AI-startup-guide.md`:
- Phase 0: bulk download + install + storage paths
- Phases 1–4: environment + verification
- Phases 5–8: AI tools + knowledge base
- Phases 9–11: dual-machine sync + final verification

### Phase 6: Verification + handoff

Verification report:
- GPU (`nvidia-smi`)
- conda envs
- PyTorch GPU
- Git / SSH
- Obsidian vault
- Caches on data drive

## Context management (critical)

If the brain AI context nears limit:
1. **Compress only after a full phase** — not mid-phase
2. Before compressing, write key state to `progress.md`
3. After compressing, read `progress.md` first
4. `progress.md` tracks: done phases / decisions / errors / next step

## Executor AI task template

```
Task: [specific task]
Input: [path / parameters]
Output: [expected result]
On completion: [report format]
```

Example:
```
Task: Extract D:\Migration\trae-skills.zip to C:\Users\[USER]\.trae-cn\skills\
Input: D:\Migration\trae-skills.zip
Output: List of extracted files
On completion: Report file count and any conflicts
```

## Exception handling

Stop and ask the user — do not guess:
1. Unclear install location
2. Driver install failure
3. GPU check failure (`nvidia-smi` error)
4. Partition size mismatch
5. Missing migration files
6. Unclear preference (which AI tool, etc.)
7. Any system-risk operation

Also follow repo-root [`AGENTS.md`](../../AGENTS.md) for planner/executor permission boundaries.

## Reference documents

- `reference/decision-flow.md`: decision trees and classification rules
- `reference/scan-script-notes.md`: scan script usage and field meanings
- `templates/startup-guide-template.md`: AI startup guide template
- `templates/scan-old-pc.ps1`: old-PC scan (local report; redacts git user and remote credentials)
- `templates/setup-env.ps1`: env setup (dangerous ops opt-in; use `-DryRun` first)
- Repo root: `02-decision-frameworks/`, `03-operation-templates/Junction-migration-template.ps1` (live runs need `-Confirm`)
- Open source: `AGENTS.md`, `PRIOR_ART.md`, `REFERENCES.md`, `NOTICE`

## Privacy and safety

1. **Do not read**: SSH private keys, browser passwords, API keys, personal files, `.env`
2. **Do not upload**: scan output stays local
3. **Redact**: usernames as placeholders; git `user.name` and remote credentials
4. **Ask first**: delete / move / overwrite
5. **No auto system ops**: registry / drivers / BIOS / disable hibernation / Defender exclusions need explicit user consent or flags
6. **Do not commit scan reports to public git** (repo `.gitignore` should ignore them)
7. **Managed devices**: do not elevate without IT approval (see `AGENTS.md` + README)

## Version

- v1.0: Initial release
