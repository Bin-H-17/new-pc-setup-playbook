# Timeline: From 8 Draft Documents to 9 Final Documents

> This document records the full evolution of the "New PC Setup Playbook" project from the initial 8 draft documents to the final 9. Each phase lists key decisions and changes for reuse and traceability.

---

## Phase 1: Initial 8 Draft Documents (Self-Drafted Skeleton)

**Goal**: Without AI involvement, use migration experience from the old PC to draft a complete skeleton and capture everything "you think you need to do."

**8 initial drafts produced**:

1. Overview (background, goals, scope)
2. Step-by-step procedures (split by phase)
3. Software inventory (classified as must-install / optional / deferred)
4. Python environment setup (conda + uv + pip mirrors)
5. Skill-MCP setup (MCP integration checklist for Cursor / Trae)
6. Folder architecture (D: drive directory tree)
7. Obsidian architecture (vault structure and plugin list)
8. Open questions (list of unresolved items)

**Key decisions**:
- "Open questions" was a separate document from the start, so open issues would not scatter across docs and get forgotten.
- An early three-layer taxonomy appeared ("foundation / fit-out / deferred"), but it was not yet strict.
- Two items in the initial draft—"migrate all of AppData to D:" and "install mem0 for long-term memory"—were later rejected.

**Remaining issues**:
- The software list was still at the "install whatever seems useful from memory" level, without scanning actual usage on the old PC.
- Cursor vs Trae roles were unclear; the two overlapped heavily.

---

## Phase 2: First Round of AI Review (Three Models, Concept Layer)

**Reviewers**: Grok, Claude Opus, and GPT in parallel, without cross-communication.

**Consensus across all three**:
- **Drop full AppData migration**: Too risky; some Electron / UWP apps hard-code absolute paths in config, and apps crash after migration.
- **Defer mem0**: mem0 changes fast; 2025 builds may be incompatible with 2026. Get the project running first.
- **Downgrade "Enforcer AI / Librarian AI"**: The original plan had AI auto-organize files and auto-archive notes. All three judged "auto-execute" as higher risk than reward; downgrade to "read-only checks + suggestions," with humans deciding whether to act.

**Other consensus**:
- Obsidian top-level folders trimmed from 9 to 5 (Inbox / Projects / Areas / Resources / Archive).
- WSL2 is required (research depends on Linux toolchains) but can be deferred until core Windows workflows work.

**Key changes**:
- Document 7 (Obsidian architecture) rewritten: 9 → 5 top-level structure.
- Document 8 (open questions): mem0 and AppData migration struck out.
- Principle introduced: "AI suggests read-only; human executes," shaping later role split.

---

## Phase 3: Second Round of AI Review (Philosophy Layer)

**Reviewers**: Same Grok / Opus / GPT, but prompts shifted to: "Skip technical details; only ask philosophy-layer questions: Is this solving real problems or creating new ones?"

**Philosophy-layer judgments from all three**:

- **Opus**: "You are reinventing the wheel." The combo of "AI auto-organize vault + auto-archive + long-term memory" is already ~80% covered by Smart Connections + Obsidian Copilot + RAG plugins; building your own duplicates that.
- **GPT**: "Maintenance explosion." Stringing mem0 / AutoGPT / custom MCP / Skills together means each component fails on its own; maintenance cost grows exponentially.
- **Grok**: "You are assembling and hardening a trendy pattern." The plan essentially glues several "looks cool" community patterns without a core thesis.

**Key changes**:
- Cut the custom "AI auto-organize + auto-archive" pipeline; use existing Obsidian plugins instead.
- mem0 downgraded further from "defer" to "do not adopt."
- "Progressive disclosure" made explicit: get baseline workflows running first; add advanced features on demand.
- After round 2, docs grew from 8 to 8 + a "Design philosophy" appendix (later merged into the overview).

---

## Phase 4: Third Round of AI Review (Technical Layer)

**Reviewers**: Grok / Opus / GPT; prompts focused on "line-by-line technical errors, especially version compatibility, driver order, path conflicts."

**Opus-only critical finding**:
- Original plan said "CUDA 12.4 + PyTorch 2.5" for RTX 5060.
- Opus noted RTX 5060 is **Blackwell architecture, compute capability = sm_120**, requiring **CUDA 12.8 + PyTorch 2.9+**. With CUDA 12.4, `torch.cuda.is_available()` returns True but running `torch.compile` crashes.
- Correct command:
  ```
  pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128
  ```

**Consensus across all three**:
- Only 3 conda envs: `med` (medical imaging) / `pde` (numerical PDE) / `math` (pure math + symbolic computation).
- Install miniconda3 only, not anaconda3 (old PC had both, wasting ~20GB).
- Do not migrate old PC conda envs; configure fresh on the new PC to avoid path pollution.

**Key changes**:
- Document 4 (Python environment) rewritten for CUDA / PyTorch.
- Document 8 added driver install order: OEM support tools (e.g. HP Support Assistant / Lenovo Vantage / Dell SupportAssist) → NVIDIA official site → Windows Update, so Windows Update does not overwrite with old drivers.
- New document "Hardware compatibility notes" (later under 05-reference-notes).

---

## Phase 5: Fourth Round of AI Review (Execution Layer)

**Reviewers**: Grok / Opus / GPT; prompts focused on "Can this actually run end-to-end? Where will it get stuck?"

**Key findings**:
- **Codex can replace ~80% of Claude Code**, without Claude Max subscription, at lower rollout cost.
- **All three warned**: Do not make Codex the sole automation hub. If everything goes through Codex, one failure stops everything. Prefer layered architecture: Codex as executor, human / large model as brain.
- **Trae and Cursor overlap**: Opus suggested picking one; user ultimately **kept both**—Cursor ecosystem is mature; Trae performs better in Chinese scenarios.
- **AGENTS.md split into two layers**: System (cross-project) + Project (project-specific), so each project is not rewritten from scratch.

**Key changes**:
- Introduced "Plan B": apps on C: + data on D:, avoiding junctioning the whole user profile and update risk.
- Introduced "layered automation": executor AI (Codex / Trae) executes; brain AI (Cursor / Opus) plans; human decides.
- Document 5 (Skill-MCP) split into "Skill setup" and "MCP setup" because maintenance cadence differs a lot.

---

## Phase 6: Fifth Round of AI Review (Detail Layer)

**Reviewers**: Grok / Opus / GPT; prompts focused on "word-by-word check of commands, paths, parameter semantics."

**Key findings**:
- **Cursor parameter semantics corrected**: `--user-data-dir` is not cache; it is user data (settings / keybindings / snippets) and belongs in Dotfiles backup. `--extensions-dir` is extensions and can be treated as disposable cache.
- **Windows Defender exclusions**: Critical data paths on D: (`D:\Code`, `D:\Datasets`, `D:\Vault`, `D:\conda`, `D:\uv`) must be excluded or I/O slows noticeably.
- **Missing uv cache config**: Plan only set `PIP_CACHE_DIR`, not `UV_CACHE_DIR`, so uv still wrote cache to C: defaults.
- Recommend a `setup-env.ps1` one-shot script for env vars + Defender exclusions + directory skeleton.

**Key changes**:
- Document 4 (Python environment) adds `UV_CACHE_DIR`.
- Document 6 (folder architecture) adds Defender exclusion list.
- New `setup-env.ps1` script (under skill templates).

---

## Phase 7: Scan Actual Usage on the Old PC

**Method**: PowerShell to extract UserAssist, Start Menu frequency, and recently modified files; cross-check "which software is actually used."

**Key findings**:
- ~30% of "must-install" items had not launched in 90 days—downgraded to optional or removed.
- Underestimated tools (PowerToys, Everything, WezTerm) ranked top 10—promoted from optional to must-install.
- Old PC had anaconda3 (~20GB) + miniconda3 (empty shell); anaconda3 used mainly via Navigator twice—new PC gets miniconda3 only.
- D: had many empty "someday project" folders; migration limited to dirs with git remote and push within 30 days.

**Key changes**:
- Document 3 (software list) reordered from scan; must-install cut from 28 to 17.
- Document 6 (folder architecture) adds "migration allowlist": only allowlisted dirs migrate.
- "Usage-evidence-driven" migration principle: no evidence, no migration.

---

## Phase 8: Cursor + Trae Role Split and Progressive Disclosure

**Goal**: Solve "AI context limit." Full PC setup text exceeds any single model's effective context; it must be split.

**Final architecture**:
- **Brain AI = Cursor / Opus**: Read full plan, plan, generate phase instructions. Read-only on filesystem.
- **Executor AI = Trae / Codex**: Execute phase instructions; after each phase write `progress.md`; brain AI reads `progress.md` to continue.
- **Human**: Confirm instructions before each phase; accept after each phase.

**Key concepts**:
- **Progressive disclosure**: Executor AI sees only current-phase instructions, not the global plan, avoiding context pollution.
- **progress.md mechanism**: Per-phase progress file for done / in progress / blocked / needs confirmation.
- **Exception protocol**: Seven cases that require stopping to ask the user (credential conflict / disk full / network failure / path conflict / version incompatibility / unclear preference / data-loss risk).

**Final output**: From 8 initial drafts to 9 final docs (Skill-MCP split into Skill + MCP), plus a "Kickoff guide template" (under skill/new-pc-setup-assistant/templates/) as the first file AI reads when taking over.

---

## Phase Overview Table

| Phase | Theme | Reviewers | Key output |
|-------|-------|-----------|------------|
| I | Self-drafted skeleton | None | 8 drafts |
| II | Concept review | Grok / Opus / GPT | Drop AppData migration; downgrade Enforcer AI |
| III | Philosophy review | Grok / Opus / GPT | Drop mem0; introduce progressive disclosure |
| IV | Technical review | Grok / Opus / GPT | CUDA 12.8 + PyTorch 2.9; 3 conda envs |
| V | Execution review | Grok / Opus / GPT | Plan B; layered automation; Codex vs Claude Code |
| VI | Detail review | Grok / Opus / GPT | Cursor parameter semantics; uv cache; Defender exclusions |
| VII | Old PC scan | Local scripts | Trim software list; migration allowlist |
| VIII | AI role architecture | Self-drafted | Brain + executor split; progress.md; 9 final docs |

---

## Document Count Over Time

- Initial: 8 documents
- After phase II: 8 (structure unchanged; content heavily revised)
- After phase V: 9 (Skill-MCP split into two)
- After phase VIII: 9 final docs + 1 kickoff guide template + 1 setup-env.ps1 script
