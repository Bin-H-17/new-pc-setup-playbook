# If I Did It Again

> Post-delivery reflection—not a "standard answer" to copy, but an honest retrospective for future me (and readers reusing this method). For a short workflow only, jump to **Streamlined Flow If I Did It Again** at the end.

---

## What Worked (Worth Keeping)

### 1. Multi-Round AI Review

**Why it worked**: Five rounds surfaced at least 3 critical errors I would not have found alone:
- CUDA 12.4 → 12.8 (Opus only in round 3; GPT and Grok missed in rounds 1–2)
- `--user-data-dir` semantics misread (round 5 detail review)
- Missing uv cache config (also round 5)

**Core value**: One model's blind spots get covered by another—but only if prompts are layered (concept / philosophy / technical / execution / detail), not one mega-prompt per round. **Five layered rounds beat five repeats of the same prompt by a wide margin.**

**Keep**: Any plan over ~1000 lines gets five review rounds. Prompt templates can be standardized (see end).

---

### 2. Three-Layer Taxonomy (Foundation / Fit-Out / Deferred)

**Why it worked**: Broke "install everything" paralysis. Hundreds of "useful-looking" tools on a new PC without taxonomy means endless second-guessing. Three layers force each tool to answer: "If the new PC could only have 10 apps, are you one?"—yes = foundation; no but big UX win = fit-out; rest = deferred.

**Effect**: Must-install list cut from 28 to 17 in the initial draft; 11 removed tools never felt "must have" after 3 months—good cuts.

**Keep**: Three-layer taxonomy applies to any migrate / reinstall / upgrade scenario, not just new PC setup.

---

### 3. Scan Actual Usage on the Old PC

**Why it worked**: Avoided "migrate from memory." UserAssist + Start Menu + Recently Modified showed ~30% of "must-install" had not launched in 90 days—pure waste if migrated.

**Insight**: **Human memory of "what I use" is unreliable.** I remember installing MATLAB; I don't remember last launch was 8 months ago. Usage data is honest.

**Keep**: Any migration task (PC / phone / cloud) starts with usage scan, then decide what to move.

---

### 4. Cursor + Trae Split (Brain AI + Executor AI)

**Why it worked**: Real fix for AI context limits. Full plan is 50k+ characters; one model eating it all loses focus on later details. Split "brain reads global plan + executor runs phases":
- Brain AI plans and writes phase instructions; no filesystem writes.
- Executor AI sees only current phase + progress.md; clean context.
- Human approves each phase.

**Key idea**: **Progressive disclosure**—executor sees only what it needs, not the whole plan. Applies beyond AI: teams, docs, any context-limited work.

**Keep**: Any long multi-step AI task uses this architecture.

---

## What Could Be Better (Next Time)

### 1. Scan the Old PC Before Writing the Plan

**Problem**: First draft was from memory; scan came after; ~30% of must-install was wrong—expensive rework.

**Reflection**: Collect facts (what the old PC actually used) before writing should (what the new PC needs). Order was reversed: should first, facts second.

**Next time**:
```
1. Scan old PC usage → 2. "Actually in use" list → 3. Add/subtract on that list → 4. Initial plan
```
Not:
```
1. Draft from memory → 2. Scan old PC → 3. Major rework
```

---

### 2. Set AI Tool Roles Earlier

**Problem**: Rounds 1–4 never pinned Cursor / Trae / Codex roles; each round re-debated "who does what." Round 5 settled "Cursor+Opus = brain, Trae+Codex = executor."

**Reflection**: Root cause was greed—maximize every tool, maximize overlap. Should have subtracted earlier.

**Next time**: Define a rough role split before round 1; later rounds refine the hypothesis, not restart from zero.

---

### 3. Plan Dual-Machine From the Start

**Problem**: Phase 7 surfaced "old PC still needed for 1–3 months"; Tailscale + Syncthing added late. Earlier planning would smooth dirs / sync / network.

**Reflection**: "New PC setup" is not a single-machine problem—it's a **dual-machine transition** for 1–3 months.

**Next time**: Version 1 states dual-machine duration, sync strategy, rollback plan.

---

### 4. Standardize Review Prompts Earlier

**Problem**: Rounds 1–3 prompts were ad hoc; rounds 4–5 stabilized templates.

**Reflection**: Prompt templates are assets—rough v1 on first review, iterate each round, not rewrite from scratch.

**Next time**: Ship a "review prompt template" (five rounds) at project start; use round 1 immediately; iterate by effect.

---

## Streamlined Flow If I Did It Again

```
1. Scan old PC
   - UserAssist data
   - Start Menu usage frequency
   - Recently modified file list
   - Output: "Actually in use" list

2. Requirements gathering
   - Next 6 months research direction (Python env / GPU needs)
   - Next 6 months writing needs (Obsidian / LaTeX)
   - Next 6 months collaboration (sync / version control)
   - Output: requirements doc

3. Generate initial plan
   - Based on scan + requirements
   - Three-layer taxonomy (foundation / fit-out / deferred)
   - Output: 8 drafts

4. Multi-round AI review (5 rounds, layered prompts)
   - Round 1: Concept (should we do this, is it worth it)
   - Round 2: Philosophy (real problem vs new problems)
   - Round 3: Technical (version compat, driver order, path conflicts)
   - Round 4: Execution (will it run, where it sticks)
   - Round 5: Detail (commands, path, parameter semantics)

5. Fix roles
   - Brain AI (plan) = Cursor / Opus
   - Executor AI (run) = Trae / Codex
   - Human (decide) = user
   - Progressive disclosure + progress.md

6. Generate artifacts
   - 9 final docs + kickoff guide template + setup-env.ps1
   - Standard directory layout

7. Execute
   - Brain AI reads kickoff guide, generates phase 0 instructions
   - Executor AI runs phase instructions
   - progress.md after each phase
   - Human accepts, next phase
```

---

## Advice for Readers

### Do Not Copy Blindly

This plan was iterated for **a math grad student in AI research**. Your needs likely differ:
- Backend engineer: skip GPU (CUDA / PyTorch) entirely.
- Designer: Python can be "install miniconda3 and stop."
- Non-research student: Obsidian + LaTeX + Zotero may be overkill.

### Worth Copying

These apply in **any** scenario:
1. **Multi-round layered AI review**: five layered prompts >> one repeated pass.
2. **Three-layer taxonomy**: foundation / fit-out / deferred—force "top 10" answer per tool.
3. **Scan old machine usage**: trust data, not memory.
4. **Brain + executor AI + progress.md**: standard fix for AI context limits.
5. **Plan B (apps on C: + data on D:)**: much safer than full AppData migration.
6. **Junction cache subdirs only, never credentials**: security floor.

### Adjust for Your Case

**Strongly customize**:
1. **Python env**: 3 conda envs (med / pde / math) are math-research specific; your names and count differ.
2. **Software list**: 17 must-install items came from my scan; yours will differ.
3. **Obsidian top 5 (PARA)**: personal KM style; Zettelkasten, GTD, etc. are fine alternatives.
4. **Codex vs Claude Code**: based on mid-2026 Codex; re-test before committing.

### One Meta Point

**Real value is not "which apps" but "how to decide what to install."** Multi-round AI review / three layers / usage data / brain-executor split are **decision methods**, not **decision results**. Results change with needs; methods transfer.

If you remember one line: **Don't configure a new PC from memory—see what you actually use with data, refine the plan with multi-round AI review, then execute with brain + executor split.**
