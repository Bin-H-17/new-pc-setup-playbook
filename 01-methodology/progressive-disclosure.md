# Progressive Disclosure Architecture: Complex Setup Within Limited AI Context

## 1. The Problem

A full new-PC setup doc can run hundreds of pages: disk partitioning, drivers, conda, Git, Cursor, Trae, Codex, Obsidian, LaTeX, Skill lists, MCP lists, migration file lists… Loading everything into AI context at once causes three failures:

1. **Context overflow**: Token limits are finite; exceed them and you get errors or forced truncation
2. **Compression loses detail**: AI compresses history to free space and drops critical specifics—e.g. "CUDA 12.8" becomes "CUDA" and the wrong version gets installed
3. **AI overreach**: Messy context leads to guessing intent—fine when right, catastrophic on irreversible decisions

**Progressive disclosure architecture** addresses all three. Core idea: **do not make AI read all docs at once—disclose by phase, each phase only what is required**.

## 2. Architecture: Brain + Executor

Two AI roles:

| Role | Tool | Responsibility | Mode |
|---|---|---|---|
| Brain | Cursor | Plan, decide, supervise | Read docs, write progress.md, instruct executor |
| Executor | Trae | Run scripts, install software, extract files | Execute brain's instructions, report back |

Why split roles? **One AI planning and executing at once drops balls**:

- Planning needs global view and long context
- Execution needs focus on the current task and frequent context resets
- Both in one session conflict

Brain AI keeps long context (overall progress). Executor AI clears context often (new session per task). They communicate via `progress.md` and explicit instruction text.

## 3. Progressive Disclosure Layers

Docs are grouped by **when they must be read**. Brain AI **reads a phase's docs only when entering that phase**—never ahead of time.

### Phase 0: Bootstrap

**Read**: Startup guide + software inventory + folder layout  
**Do**: Build mental model; confirm disk layout and user directory structure  
**Do not read**: Any tool-specific configuration docs

### Phase 1–4: Python Environment

**Read**: Python environment setup doc  
**Do**: Install NVIDIA driver, CUDA, conda, PyTorch  
**Critical**: Must finish this phase before the next—later AI tools depend on Python env

### Phase 5: AI Tools and Skill/MCP

**Read**: Skill list + MCP list  
**Do**: Configure Cursor/Trae/Codex; register Skills and MCPs  
**Do not read**: Obsidian docs (avoid context pollution)

### Phase 6–8: Obsidian + Notes

**Read**: Obsidian architecture doc  
**Do**: Create vault, install plugins, configure templates  
**Do not read**: Python env docs (already done)

Essence: **load only context required for the current task; unload when done**. AI attention is scarce—don't spend it on docs for "later."

## 4. Context Management: progress.md

Brain AI's "long-term memory" is not the context window—it is a file: `progress.md`.

### What progress.md Records

After each phase, before compressing context, brain AI must write:

```markdown
## Completed Phases
- [x] Phase 0: Disk layout (C: 160 GB / D: remainder), user directories confirmed
- [x] Phase 1–4: Python env (CUDA 12.8 + conda + PyTorch 2.9)
- [ ] Phase 5: AI tool setup (in progress)

## Decision Points
- conda env path: D:\conda\envs (reason: C: too small; conda path is redirectable)
- CUDA version: 12.8 (reason: RTX 5060 is Blackwell sm_120, requires 12.8+)
- Cursor --user-data-dir: Dotfiles (reason: must back up)
- Cursor --extensions-dir: Caches (reason: disposable; reinstall restores)

## Exceptions
- Phase 3 PyTorch install: pip mirror timeout; switched to Tsinghua mirror
- Phase 4 conda env: default Python 3.12; manually set to 3.11 (reason: dependency not on 3.12 yet)

## Next Steps
- Enter Phase 5: configure Trae and Codex
- Note: Codex API key must be entered by user—cannot auto-generate
```

### When to Compress

**Only after progress.md is written** may brain AI compress history. Non-negotiable—compressing without progress.md equals data loss.

### Three Roles of progress.md

1. **Survives compression**: After context compression, progress.md is the restore point
2. **Cross-session resume**: Next day, brain reads progress.md and knows where you stopped
3. **Exception trail**: If a phase fails, the Exceptions section is the debugging record

## 5. Migration File Handling

Files from the old machine are usually zip archives (notes, config, cache). Brain AI **never reads zip contents**—one read blows context.

Correct flow: **brain tells executor extraction paths only**:

```markdown
## Task
Extract D:\migration\obsidian-vault.zip to D:\Obsidian\Vault

## Input
- File path: D:\migration\obsidian-vault.zip
- Target path: D:\Obsidian\Vault

## Output
- Directory tree after extract (first two levels)
- Total file count
- Conflicts (same names already at target)

## Report Back
Return output in the format above to brain AI
```

Brain decides next steps from the executor's report—not by reading the zip.

## 6. Executor Instruction Template

Executor does not need global context—only **this task**. Template:

```markdown
## Task
[One sentence, e.g. "Create conda env py311-torch"]

## Input
- [Required params, e.g. "Python 3.11 / PyTorch 2.9.0+cu128"]
- [Path constraints, e.g. "env path must be under D:\conda\envs"]

## Output
- [Expected result, e.g. "env created and import torch works"]
- [Report format, e.g. "print torch.cuda.is_available()"]

## Completion Report Format
1. Status: success / failure / partial
2. Key output: [command output / paths / verification]
3. Exceptions: [what happened + how you handled it]
4. Uncertainties: [list for brain to confirm]

## Boundaries
- Do not work outside task scope
- Stop and report on uncertainty—do not decide alone
```

The **Boundaries** line matters most—executors often "while I'm here…" and touch irreversible decisions.

## 7. Exception Handling: Stop and Ask the User

The most important rule: **when uncertain, stop and ask the user—do not decide alone**.

| Decision type | Handling |
|---|---|
| True foundation (disk/CUDA/conda path/SSH keys) | **Must** stop for user confirmation—even at 90% confidence |
| Fit-out (plugins/templates/themes) | May try on your own; record in progress.md what and why |
| Defer items | Skip; do not execute |
| Unclear layer | Treat as true foundation—stop and ask |

Why so strict? AI overreach on irreversible choices is expensive. Example: AI decides "conda on C: is fine," installs 20 GB of deps, migration cost explodes later.

This rule belongs in AGENTS.md so every AI reads it before acting.

## 8. Why This Architecture Works

### 1. Fixes Context Overflow

Each phase loads only required docs—context drops from "everything" to "this phase." Phases that used to overflow now fit.

### 2. Fixes Compression Data Loss

progress.md is **active persistence**—write critical facts before compressing. Compression drops chat history; files do not.

### 3. Fixes AI Overreach

- Brain has global view → can classify decision layer
- Executor sees one task → no global scope to overstep
- AGENTS.md: true foundation requires user confirmation

Three layers of defense keep irreversible mistakes rare.

### 4. Fixes Cross-Session Resume

New PC setup spans days. Day two: read progress.md → exact state—done, decisions, exceptions, next step. Context window alone cannot do that.

### 5. Fixes "AIs Don't Know What the Other Is Doing"

Brain and executor communicate via progress.md and explicit instructions—not shared context:

- Executor sessions can be cleared freely; brain unaffected
- Brain can assign parallel executor tasks (if non-conflicting)
- Any AI crash → progress.md is the recovery point

## 9. Comparison to Other Architectures

### vs Single-AI Full Automation

Intuitive—"one AI configures everything end to end." Problems:

- Context overflow on hundred-page docs
- Compression drops details
- Overreach when context degrades

Progressive disclosure fixes each via **phasing + progress.md + brain/executor split**.

### vs Pure Manual Phasing

Manual phasing avoids overflow but loses AI assistance—human reads every doc every phase. Progressive disclosure keeps AI fully automated **within** each phase; humans only at phase boundaries and irreversible decisions.

## 10. Usage Recommendations

1. **Keep phases to 6–10.** Too few → single phase still too large; too many → switching cost exceeds benefit.
2. **Each phase needs a completion criterion.** e.g. Phase 1–4 done when `torch.cuda.is_available()` is True.
3. **Back up progress.md daily.** It is the architecture's long-term memory—lose it, lose state.
4. **Discard executor sessions after use.** New session per task; report and close—do not reuse.
5. **Document "stop and ask" triggers in AGENTS.md.** So AI knows what it must not decide alone.

Progressive disclosure admits **AI context is finite** and engineers allocation to where it matters most. It does not make AI smarter—it stops AI from failing stupidly on context management.
