# AI Tool Division Matrix

> Progressive disclosure principle: AI brain plans, AI executor works, AI automation watches the shop.
> Don't let one AI do everything — context explodes and errors propagate.

---

## 1. Three-Layer AI Tool Division

### 🧠 Brain Layer (Planning / Decision / Oversight)

| Role | Recommended Tool | Primary Responsibilities |
|------|------------------|--------------------------|
| Planning | Cursor or Trae (IDE class) | Read docs, break down tasks, write plans, supervise executors |
| Decision-making | Same as above | Choose among options, weigh trade-offs |
| Oversight | Same as above | Review executor output; stop immediately on errors |

**Traits**: Human-led, AI-assisted. Human-in-the-loop.

### ⚙️ Executor Layer (Run Scripts / Install Software / Extract Files)

| Role | Recommended Tool | Primary Responsibilities |
|------|------------------|--------------------------|
| Execution | Trae or Codex (CLI class) | Receive brain instructions, run PowerShell / Bash |
| Delivery | Same as above | Extract, copy, move, install packages |
| Feedback | Same as above | Return results (success / failure / output) to the brain |

**Traits**: AI-led, human-supervised. Executors **do not read docs — they only receive explicit instructions**.

### 🤖 Automation Layer (Scheduled Tasks / Background Runs)

| Role | Recommended Tool | Primary Responsibilities |
|------|------------------|--------------------------|
| City Manager AI | Codex exec non-interactive mode | Scheduled disk scans, cleanup recommendations |
| Librarian AI | Codex or OpenClaw | Obsidian index generation, knowledge base organization |
| Watchdog | Task Scheduler + Codex | System health monitoring, anomaly alerts |

**Traits**: No human intervention; triggered on schedule; results written to logs / push notifications.

---

## 2. Tool Selection Comparison Table

| Tool | Type | Capability Boundary | Best Role |
|------|------|---------------------|-----------|
| **Cursor** | IDE (GUI) | Code editing + AI chat + terminal + mature extension ecosystem | Brain (primary) |
| **Trae** | IDE (GUI) | Code editing + AI chat + terminal + China-friendly access | Brain (primary / backup) |
| **Trae Solo** | Simplified IDE | Single-file editing + AI chat, lightweight | Brain (lightweight scenarios) |
| **Trae Work** | Collaboration edition | Multi-user collaboration + task management + shared context | Brain (team scenarios) |
| **Codex CLI** | CLI (terminal) | Pure command-line execution + script runs + non-interactive mode | Executor + Automation |

### Detailed Capability Comparison

| Dimension | Cursor | Trae | Trae Solo | Trae Work | Codex CLI |
|-----------|--------|------|-----------|-----------|-----------|
| Code editing | ✅ Full | ✅ Full | ⚠️ Simplified | ✅ Full | ❌ |
| AI chat | ✅ | ✅ | ✅ | ✅ | ⚠️ Limited |
| Terminal integration | ✅ | ✅ | ❌ | ✅ | ✅ (native) |
| Extension ecosystem | ✅ Full VS Code | ✅ Full VS Code | ⚠️ Limited | ✅ Full VS Code | ❌ |
| Non-interactive mode | ❌ | ❌ | ❌ | ❌ | ✅ `codex exec` |
| Scheduled-task friendly | ❌ | ❌ | ❌ | ❌ | ✅ |
| China access | ⚠️ Proxy needed | ✅ Friendly | ✅ | ✅ | ⚠️ Depends on config |
| Multi-user collaboration | ❌ | ⚠️ Limited | ❌ | ✅ | ❌ |
| Context window | Large | Large | Medium | Large | Medium |

---

## 3. Division Principles

### Principle 1: Brain reads docs + plans; executor does not read docs — only receives instructions

**Anti-pattern (don't do this)**:
> User: Install conda
> Executor AI: (searches conda install docs on its own) → installs wrong version

**Correct pattern**:
> User → Brain AI: Install conda
> Brain AI: (reads official docs + project README) → outputs explicit instructions:
>   1. Download Miniconda3-latest-Windows-x86_64.exe
>   2. Silent install to C:\Miniconda3
>   3. Configure .condarc to point to D:\Environments\conda
>   4. Verify `conda --version`
> Executor AI: (runs commands one by one, no thinking) → returns output
> Brain AI: (checks output) → confirms success / handles errors

### Principle 2: Brain decides; executor only executes

- Executors **don't make choices** — stop and ask the brain at any branch point
- Brain **doesn't run commands directly** (except one-off small ops in the IDE's built-in terminal)

### Principle 3: Executor handles one atomic task at a time

- ❌ Don't: "Migrate all caches to D:"
- ✅ Do: "Run this PowerShell command: `[System.Environment]::SetEnvironmentVariable('PIP_CACHE_DIR', 'D:\Caches\pip', 'User')` and return the output"

### Principle 4: Automation layer runs on schedule, not in real time

- City Manager AI runs once daily at midnight; results go to a log
- Don't have AI monitor disk usage in real time (wastes resources + explodes context)

---

## 4. City Manager AI (Disk Scan + Cleanup Recommendations)

### Role

Scheduled disk usage scan, generate cleanup recommendations, **never auto-delete** (deletion requires user confirmation).

### Implementation: Codex exec Non-Interactive Mode

**Trigger**: Windows Task Scheduler + Codex exec

**Example command**:

```powershell
# Task Scheduler invokes Codex exec
codex exec --non-interactive "Scan D:\Caches directory, list Top 10 subdirectories by size, and for directories over 5 GB provide cleanup recommendations (keep / safe to clear / compress). Output Markdown report to D:\Logs\disk-scan-$(Get-Date -Format yyyyMMdd).md"
```

### Task Scheduler Configuration

```powershell
# Create scheduled task (runs daily at 3 AM)
$action = New-ScheduledTaskAction -Execute "codex" -Argument "exec --non-interactive `"...`""
$trigger = New-ScheduledTaskTrigger -Daily -At 3am
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -DontStopOnIdleEnd

Register-ScheduledTask -TaskName "CityManager-AI-DiskScan" `
    -Action $action -Trigger $trigger -Settings $settings `
    -Description "AI City Manager: daily disk scan + cleanup recommendations"
```

### Sample Output

```markdown
# Disk Scan Report 2026-07-20

## D:\Caches Top 10

| Directory | Size | Recommendation |
|-----------|------|----------------|
| huggingface\hub | 87 GB | Keep (models — expensive to re-download) |
| pip | 3.2 GB | Safe to clear (`pip cache purge`) |
| npm | 1.8 GB | Safe to clear (`npm cache clean --force`) |
| uv | 1.2 GB | Safe to clear (`uv cache clean`) |
| Cursor | 0.8 GB | Compressible (clear old extension versions) |

## Recommended Actions

1. `pip cache purge` → free 3.2 GB
2. `npm cache clean --force` → free 1.8 GB
3. Manually review old Cursor extension versions
```

---

## 5. Librarian AI (Obsidian Index Generation)

### Role

Scan the Obsidian knowledge base; generate / update index files (MOC, tag index, link graph).

### Implementation: Codex or OpenClaw

**Trigger**: Manual + scheduled (weekly)

**Example**:

```powershell
codex exec --non-interactive "Scan all .md files under D:\Knowledge\Obsidian and generate: 1) index grouped by #tags; 2) orphan notes list (in-degree 0); 3) MOC candidates (notes referenced ≥ 5 times). Output to D:\Knowledge\Obsidian\INDEX.md"
```

### Output Structure

```
D:\Knowledge\Obsidian\
├── INDEX.md              # Main index (auto-generated)
├── INDEX-by-tag.md       # Tag index
├── INDEX-orphans.md      # Orphan notes
└── INDEX-moc-candidates.md  # MOC candidates
```

---

## 6. Safety Principles (Red Lines)

### 🚫 Things AI Must Never Do

| Operation | Reason | Must Be Done By |
|-----------|--------|-----------------|
| Edit registry (system-level) | High risk — can prevent boot | User manually |
| Install drivers | Wrong driver breaks everything | User manually + official installer |
| Change BIOS / UEFI | Hardware-level risk | User manually |
| Format disks | Data loss risk | User manually |
| Modify user account permissions | Security risk | User manually |
| Delete system files | System crash | User manually |
| Disable firewall / antivirus | Security risk | User manually |
| Change network config (DNS / proxy) | Affects connectivity | User confirms before execution |

### ✅ Things AI Can Do

| Operation | Condition |
|-----------|-----------|
| Run conda / pip / npm commands | User-level; doesn't affect system |
| Create / delete D: directories | Operations on data drive only |
| Modify user-level environment variables | Doesn't affect system-level |
| Generate config files | Takes effect only after user review |
| Scan disk / generate reports | Read-only operations |
| Create junctions | Within data drive scope |

### Verification Mechanism

**Before any executor "write operation", the brain AI must output a command preview for user confirmation**:

```
[Brain AI] About to have the executor run the following command:
  mklink /J "C:\Users\X\AppData\Roaming\Trae\Cache" "D:\Caches\Trae\Cache"
Continue? (y/n)
```

---

## 7. Context Management

### Problem

The longer an AI conversation runs, the fuller context gets, leading to:
- Forgetting early decisions
- Re-reading the same file repeatedly
- Treating old errors as new problems

### Solution: Phase Compression + progress.md

### Phase Compression

After each phase completes, the brain AI **actively compresses**, retaining key information:

```
[Phase: Partitioning complete]
Key decisions:
- C 160GB / D 690GB / O 80GB
- Volume labels: Data / Knowledge
- System restore disabled

Next step: Install drivers
```

### progress.md File

Maintain a `progress.md` in the project working directory; append a section after each phase:

```markdown
# New PC Setup Progress

## 2026-07-20 Phase 1: Partitioning
- ✅ C 160GB / D 690GB / O 80GB
- ✅ Volume labels set
- ✅ System restore disabled
- ⚠️ Virtual memory pending migration to D:

## 2026-07-20 Phase 2: Drivers
- ✅ NVIDIA driver 5xx.xx
- ✅ CUDA 12.8 (Blackwell sm_120)
- ✅ Chipset drivers
- ⚠️ Network driver pending after Windows Update

## Next Steps
- [ ] Windows Update
- [ ] conda install
- [ ] Git + SSH
```

### Context Refresh Strategy

- After completing each phase, start a new conversation window
- Paste `progress.md` contents as the starting point for the new conversation
- Keep old conversations for reference — don't continue them

---

## 8. Division Workflow Example

### Scenario: Migrate Cursor Cache to D:

```
User → Brain AI (Cursor/Trae):
  "Migrate Cursor user data and extensions to D:"

Brain AI:
  1. Read project docs (cache-migration-table.md)
  2. Output plan:
     - Create D:\Dotfiles\Cursor\UserData
     - Create D:\Caches\Cursor\Extensions
     - Modify shortcut launch arguments
  3. Break into atomic tasks, send to executor one by one

Brain AI → Executor AI (Codex CLI):
  Task 1: mkdir D:\Dotfiles\Cursor\UserData
  Executor: ✅ Done

  Task 2: mkdir D:\Caches\Cursor\Extensions
  Executor: ✅ Done

  Task 3: Backup old data Copy-Item ...
  Executor: ✅ Done

Brain AI → User:
  "Please manually edit the Cursor shortcut target to:
   ... --user-data-dir=... --extensions-dir=...
   Tell me when done and I'll have the executor verify"

User: (edits shortcut manually) → "Done"

Brain AI → Executor AI:
  Task 4: Launch Cursor and verify user data directory
  Executor: ✅ Path correct

Brain AI → User:
  "Migration complete — recorded in progress.md"
```

---

## 9. Checklist

- [ ] Brain AI selected (Cursor or Trae)
- [ ] Executor AI selected (Codex CLI or Trae CLI)
- [ ] progress.md path configured
- [ ] Safety red lines reviewed
- [ ] City Manager AI scheduled task set up (optional)
- [ ] Librarian AI set up (optional)
