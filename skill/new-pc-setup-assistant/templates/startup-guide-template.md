# Startup guide template

> **This is the first file the executor AI reads after taking over new-PC setup.**
>
> This is a **template**. User-specific values use `{{placeholder}}`. On first run, the brain AI should read scan results, requirements, and the finalized plan, produce a **custom startup guide** (replace all placeholders), then begin execution.
>
> Template path: `skill/new-pc-setup-assistant/templates/startup-guide-template.md`. Save the customized copy in the user's working directory as `startup-guide.md`.

---

## 1. Your role and architecture

### 1.1 Three-way split

You (AI) are the **executor AI**. Full collaboration model:

- **Brain AI ({{brain_ai_name}}, e.g. Cursor / Claude Opus)**
  - Reads the full plan; plans and emits phased instructions.
  - Read-only on the filesystem for planning.
  - Does not install software or change config directly.
  - Issues a "phase brief" before each phase for the executor.

- **Executor AI ({{executor_ai_name}}, e.g. Trae / Codex) = you**
  - Executes phase briefs.
  - After each phase, updates `progress.md` (done / in progress / blocked / needs user).
  - Stops and asks the user on anomalies; no silent decisions.
  - Does not read the global plan — only current phase brief + `progress.md`.

- **Human ({{user_label}})**
  - Confirms each phase brief before start.
  - Accepts each phase at the end.
  - Resolves preferences AI cannot decide (app choice, folder names).

### 1.2 Progressive disclosure

You (executor) only read:
1. This startup guide (customized)
2. Current phase brief
3. `progress.md` (history)

**Do not read the full plan docs** (overview / full checklist / full software list) to avoid context pollution. If the phase brief is inconsistent or incomplete, **stop and ask the brain AI or user** — do not fill gaps yourself.

---

## 2. Prerequisites

Before phase 0, confirm the user completed:

- [ ] New PC booted, online, signed in (Microsoft or local account)
- [ ] Old-PC migration data exported to: `{{migration_data_path}}` (e.g. `D:\Migration` or `E:\Migration`)
- [ ] User has credentials ready (do not store in files; ask when needed):
  - GitHub PAT
  - Obsidian Sync (if used)
  - WeChat QR login
  - Email account
  - {{other_credentials}}
- [ ] Brain and executor tools confirmed ({{brain_ai_tool}} / {{executor_ai_tool}})
- [ ] Custom startup guide reviewed (all placeholders filled)

If any item is missing, **stop and ask** — do not proceed.

---

## 3. Migration file inventory

User placed old-PC data at `{{migration_data_path}}`. Expected layout:

| Subfolder | Contents | Target | Method |
|-----------|----------|--------|--------|
| `Dotfiles/` | Git repo (.gitconfig / PowerShell profile / Cursor config, etc.) | `D:\Dotfiles` | `git clone` or copy |
| `Code/` | Projects (only repos with remote + push in last 30 days) | `D:\Code\<repo>` | `git clone` each |
| `Vault/` | Obsidian vault | `D:\Vault` | Full directory copy |
| `Datasets/` | Datasets | `D:\Datasets` | Full directory copy |
| `Latex/` | LaTeX sources | `D:\Latex` | Full directory copy |
| `Zotero/` | Zotero DB + attachments | `D:\Zotero` | Full directory copy |
| `WeChat/` | Chat DB + key files (text) | `D:\WeChat` | Copy; change WeChat file path in app |
| `conda-envs/` | `environment.yml` per env | `D:\conda\envs\<name>` | Recreate from yml; do not copy env dirs |
| `SSH-Keys/` | SSH private + public keys | `~/.ssh/` (default on C:) | Copy; fix permissions |
| `{{other_subfolder}}` | {{description}} | {{target_path}} | {{method}} |

### Principles

1. **Credentials (SSH-Keys / .aws / .gnupg) stay on C: default paths** — do not move to D:.
2. **Code (Code / Dotfiles): prefer `git clone` over copy** for clean repos.
3. **Large dirs (Datasets / Latex): copy then verify with `robocopy`.**
4. **conda envs: rebuild from `environment.yml`** — avoid path pollution from copying env folders.
5. **After each migration, run `Get-FileHash`** to verify integrity.

---

## 4. Execution phases

Setup runs in **phases 0–11** (12 total). Each has entry, exit, and acceptance criteria. **Do not start the next phase until the current one passes acceptance.**

### Phase 0: Environment base (setup-env.ps1)
- **Entry**: All prerequisites met.
- **Tasks**: Run `setup-env.ps1` — env vars, optional Defender exclusions, directory skeleton.
- **Exit**:
  - Under `D:\`: `Code`, `Datasets`, `Vault`, `conda`, `uv`, `Cache`, `Dotfiles`, `Migration`, etc.
  - Cache env vars set (`PIP_CACHE_DIR`, `UV_CACHE_DIR`, `POETRY_CACHE_DIR`, `PDM_CACHE_DIR`, npm cache).
  - Defender exclusions added (if enabled in plan).
- **Acceptance**: User runs `Get-ChildItem D:\`; `echo $env:UV_CACHE_DIR` shows expected path.

### Phase 1: Drivers and Windows Update
- **Entry**: Phase 0 accepted.
- **Tasks**: Drivers in order (OEM tool → NVIDIA Studio Driver → Windows Update, excluding duplicate NVIDIA from WU if needed).
- **Exit**: `nvidia-smi` shows RTX {{gpu_model}}, Driver Version ≥ {{min_driver_version}}, CUDA Version ≥ {{min_cuda_version}}.
- **Acceptance**: User shares `nvidia-smi` output.

### Phase 2: Foundation software
- **Entry**: Phase 1 accepted.
- **Tasks**: Install foundation-tier apps ({{foundation_app_count}} items).
- **Exit**: Each app launches; versions match plan.
- **Acceptance**: User confirms Start menu icons.

### Phase 3: Python environment
- **Entry**: Phase 2 accepted.
- **Tasks**:
  - Install miniconda3 to `D:\conda`.
  - `conda config --set pkgs_dirs D:\conda\pkgs`.
  - Recreate {{conda_env_count}} envs from yml ({{env_list}}).
  - In `med` env: PyTorch (`--index-url https://download.pytorch.org/whl/cu128`).
  - Run 6-step GPU verification (see hardware compatibility notes in plan bundle).
- **Exit**: All 6 steps pass.
- **Acceptance**: `torch.cuda.get_device_capability()` returns `({{sm_major}}, {{sm_minor}})`.

### Phase 4: Dev tools (Cursor / Trae / Codex)
- **Entry**: Phase 3 accepted.
- **Tasks**:
  - Cursor with `--user-data-dir=D:\Dotfiles\Cursor --extensions-dir=D:\Cache\Cursor\ext`.
  - Trae: Junction cache subdirs to `D:\Cache\TraeWork\` (do not move `%APPDATA%\Trae Work` root).
  - Codex CLI: `codex auth`.
  - `AGENTS.md` two-layer layout (System + Project).
- **Exit**: All three tools work; Cursor opens projects; Trae runs commands; `codex --version` OK.
- **Acceptance**: User opens `D:\Dotfiles` in Cursor; config applied.

### Phase 5: Obsidian and notes
- **Entry**: Phase 4 accepted.
- **Tasks**:
  - Obsidian → open `D:\Vault`.
  - Core plugins ({{plugin_list}}).
  - Five top folders: Inbox / Projects / Areas / Resources / Archive.
  - Smart Connections + Obsidian Copilot.
- **Exit**: Vault opens; plugins enabled.
- **Acceptance**: User confirms sidebar structure.

### Phase 6: Data migration
- **Entry**: Phase 5 accepted.
- **Tasks**: Migrate per section 3 inventory.
- **Exit**: Each item passes `Get-FileHash`.
- **Acceptance**: User spot-checks 3 files open correctly.

### Phase 7: Skills and MCP
- **Entry**: Phase 6 accepted.
- **Tasks**:
  - MCP servers ({{mcp_list}}).
  - Skill packages ({{skill_list}}).
  - Test each MCP / Skill once.
- **Exit**: At least one successful call per MCP / Skill.
- **Acceptance**: User confirms MCP panel green.

### Phase 8: Junctions and cache cleanup
- **Entry**: Phase 7 accepted.
- **Tasks**:
  - Junction Electron app cache dirs (Trae / Cursor / VS Code / Chrome) to D:.
  - **Do not Junction credential dirs** (`.trae-cn`, `.codex`, `.aws`, `.ssh`, `.gnupg`).
  - Clean C: temp files.
- **Exit**: Apps launch after Junction; C: free space increased.
- **Acceptance**: User launches each app once.

### Phase 9: Dual-machine sync (optional)
- **Entry**: Phase 8 accepted; user opted in.
- **Tasks**:
  - Tailscale login.
  - Syncthing shared folders ({{syncthing_folders}}).
  - Old + new PC discover each other.
- **Exit**: Ping works; Syncthing "Connected".
- **Acceptance**: Test file syncs old → new.

### Phase 10: Fit-out software (optional)
- **Entry**: Phase 9 accepted (or skipped).
- **Tasks**: Install fit-out tier ({{fitout_app_count}} apps) by user priority.
- **Exit**: Each app launches.
- **Acceptance**: User confirms.

### Phase 11: Acceptance and archive
- **Entry**: Phase 10 accepted.
- **Tasks**:
  - Full acceptance checklist (below).
  - Archive `progress.md` to `D:\Dotfiles\new-pc-setup\`.
  - Clean temp (`C:\Temp\*`, leftover downloads).
- **Exit**: Checklist all ✓.
- **Acceptance**: User final sign-off.

---

## 5. Execution principles

### Principle 1: When unsure, ask
For version choice, folder names, feature toggles — **stop and ask**. Be specific; avoid open-ended questions.

### Principle 2: Install paths from the plan only
C: default vs D: custom must match the plan. **Do not "close enough" path changes** — Junctions, Defender exclusions, and backup depend on them.

### Principle 3: Compress context only after a phase completes
**Update `progress.md`** and wait for brain or user acceptance before the next phase. If interrupted, resume from last line in `progress.md`.

### Principle 4: No unprompted upgrades or downgrades
Plan versions are compatibility-checked. **Do not upgrade "because newer"** or downgrade "for stability" without brain review.

### Principle 5: Keep `progress.md` live
Update after each sub-task, not only at phase end. On interrupt, `progress.md` is the source of truth.

### Principle 6: Do not read the global plan
Only phase brief + `progress.md`. On contradiction, stop and ask.

---

## 6. Context management (`progress.md`)

### 6.1 Location

`{{working_directory}}\progress.md`

### 6.2 Structure

```markdown
# New PC setup progress

## Basics
- Started: {{start_time}}
- Current phase: {{current_phase}}
- User: {{user_label}}
- Brain AI: {{brain_ai_tool}}
- Executor AI: {{executor_ai_tool}}

## Phase status

### Phase 0: Environment base
- Status: ✅ Done / 🔄 In progress / ⏸️ Blocked / ⏭️ Skipped
- Started: {{time}}
- Finished: {{time}}
- Done:
  - [x] Directory skeleton
  - [x] Environment variables
  - [ ] Defender exclusions
- Blocked:
  - {{block_description}}
- Needs user:
  - {{pending_description}}
- Notes: {{notes_for_later_phases}}

### Phase 1: Drivers and updates
- Status: ⏳ Not started
- ...

## Cross-phase notes
- {{global_notes}}

## Open questions for user
- [ ] {{question_1}}
- [ ] {{question_2}}
```

### 6.3 Update rules

1. Check off sub-tasks immediately when done.
2. Update phase status when it changes.
3. Log blocks as they happen.
4. Record user decisions in cross-phase or open-questions sections.
5. **Append only** — mark stale info `[superseded]`, do not delete history.

### 6.4 Handoff

**Brain AI resumes:**
1. Read current phase in `progress.md`.
2. If incomplete, brief remaining sub-tasks.
3. If done but not accepted, brief acceptance.
4. If accepted, brief next phase.

**Executor AI resumes:**
1. Read `progress.md` for current phase.
2. Read phase brief.
3. Continue from first unchecked item after last completed.

---

## 7. Phase brief template

Brain AI generates; executor follows:

```markdown
# Phase {{N}}: {{phase_name}} — execution brief

## Context
- Current phase: {{N}}
- Previous phase: {{previous_phase_status}}
- Goal: {{one_line_goal}}

## Entry (all required)
- [ ] {{entry_1}}
- [ ] {{entry_2}}

## Task list
1. **{{task_1_title}}**
   - Command: {{steps}}
   - Expected: {{expected_output}}
   - On failure: {{failure_handling}}

2. **{{task_2_title}}**
   - Command: {{command}}
   - Expected: {{expected_output}}
   - On failure: {{failure_handling}}

...

## Exit (all required)
- [ ] {{exit_1}}
- [ ] {{exit_2}}

## Acceptance
- {{acceptance_description}}

## Exceptions
- Stop and ask user if:
  - {{exception_1}}
  - {{exception_2}}
- Other cases: section 8 general protocol.

## After completion
- Update `progress.md` → phase ✅ Done.
- Notify user for acceptance.
- Wait for acceptance; request next phase brief from brain AI.
```

---

## 8. Exception handling

Stop and ask the user for these **seven cases** — do not auto-recover:

### 1. Credential conflict
- **Sign**: Existing credentials differ from plan.
- **Example**: Codex logged into another account; Obsidian Sync bound to another device.
- **Why stop**: Overwrite may disconnect old device.
- **Ask**: "Existing {{account_type}} credentials detected. Overwrite? Old device may need re-login."

### 2. Low disk space
- **Sign**: C: < 20 GB free or D: < 100 GB free.
- **Why stop**: Risk of failed install or system instability.
- **Ask**: "C: {{X}} GB / D: {{Y}} GB free — below threshold. Pause to clean up?"

### 3. Network failure
- **Sign**: 3 consecutive download failures; GitHub / npm / pip unreachable.
- **Why stop**: Partial packages possible.
- **Ask**: "{{source}} failed 3 times. Switch mirror / wait / skip step?"

### 4. Path conflict
- **Sign**: Target exists, non-empty, not expected legacy data.
- **Why stop**: Overwrite vs skip both risky.
- **Ask**: "{{path}} exists ({{brief_contents}}). Merge / overwrite / skip?"

### 5. Version mismatch
- **Sign**: Installed version ≠ plan (e.g. CPU PyTorch, wrong CUDA).
- **Why stop**: Later phases may all fail.
- **Ask**: "{{package}} is {{X}}, expected {{Y}}. Reinstall / accept / pause?"

### 6. Unclear user preference
- **Sign**: Plan says "user preference" but none recorded.
- **Why stop**: Wrong choice → rework.
- **Ask**: "Choose {{decision_item}}: {{options}}."

### 7. Data loss risk
- **Sign**: Operation may overwrite/delete data (`Move-Item` to existing target, `git push --force`, etc.).
- **Why stop**: Irreversible.
- **Ask**: "{{command}} may lose {{data_description}}. Backed up? Continue?"

### General protocol

For other errors:
1. **Max 2 retries** — third failure → stop.
2. Log to `progress.md` blocked section.
3. Ask: "Phase {{N}} task {{M}} failed: {{description}}. Log: {{log}}. A) Retry B) Skip C) Pause?"

---

## Appendix: How to use this template

### For brain AI

On first takeover:
1. Read scan report + requirements + finalized plan.
2. Replace all `{{placeholders}}`.
3. Save as `{{working_directory}}/startup-guide.md`.
4. Generate phase 0 brief for executor.

### For executor AI

On first takeover:
1. Read `{{working_directory}}/startup-guide.md` (no placeholders left).
2. Read `progress.md` if present (resume) or start phase 0.
3. Wait for phase brief from brain.
4. Execute per sections 5 and 8.

### For the user

This template is for AI, not a manual checklist. Your job:
1. Review customized startup guide after brain fills placeholders.
2. Accept each phase seriously.
3. Answer executor questions promptly.
4. Stop immediately if something is wrong — do not wait until phase end.

If customized guide still shows `{{...}}`, brain missed a field — ask it to complete.

---

**Version**: v1.0  
**Last updated**: {{last_updated}}  
**Project**: New PC Setup Playbook
