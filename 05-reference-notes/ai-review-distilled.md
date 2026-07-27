# AI Review Findings (Distilled)

> Distilled key findings from five rounds of AI review (Grok / Claude Opus / GPT). **No verbatim quotes**—only conclusions and corresponding plan changes. Full review transcripts live in project history archives (outside this repo).

---

## Round 1: Concept Review (Should We Do This? Is It Worth It?)

### Scope
- 8 draft documents
- Early three-layer taxonomy
- AppData migration plan
- mem0 adoption plan
- Enforcer AI / Librarian AI auto-execute plan

### Consensus Across All Three

1. **Drop full AppData migration**
   - Risks: Electron / UWP absolute path hardcoding, ACL inheritance, AppContainer sandbox limits.
   - Alternative: junction individual app Cache subdirs on demand.

2. **Defer mem0**
   - mem0 evolves fast; 2025 vs 2026 builds may be incompatible.
   - Run baseline workflows first; revisit long-term memory when the ecosystem stabilizes.

3. **Downgrade Enforcer AI / Librarian AI**
   - Original: AI auto-organize files, auto-archive notes, auto-rename.
   - Downgraded: AI read-only checks + suggestions; human decides execution.
   - Reason: auto-execute risk > reward; wrong rename/archive recovery cost exceeds manual archive cost.

### Other Consensus

4. **Trim Obsidian top-level folders**
   - Original: 9 top folders (mixed discipline / project type / time).
   - Changed to: 5 (Inbox / Projects / Areas / Resources / Archive)—PARA.
   - Reason: finer top taxonomy increases filing friction; everything ends in Inbox.

5. **WSL2 required but can defer**
   - Research needs Linux toolchains (some libs source-only).
   - Defer until core Windows workflows work—avoid early distraction from Linux subsystem.

### Plan Changes

- Document 7 (Obsidian architecture) rewritten: 9 → 5 top level.
- Document 8 (open questions): strike mem0 and AppData migration.
- Principle: AI read-only suggestions; human executes.

---

## Round 2: Philosophy Review (Real Problems vs New Problems)

### Scope
- Revised 8 documents
- "AI auto-organize + auto-archive + long-term memory" pipeline
- Rationale for custom MCP / Skill stack

### Philosophy-Layer Judgments

1. **"You are reinventing the wheel"** (Opus)
   - "AI auto-organize vault + auto-archive + long-term memory" is ~80% covered by Smart Connections + Obsidian Copilot + RAG plugins.
   - Building your own redoes mature plugins; quality likely worse.
   - Conclusion: use mature plugins for 80%; consider custom only for real remaining pain.

2. **"Maintenance explosion"** (GPT)
   - String mem0 / AutoGPT / custom MCP / Skills → 5+ components, each fails independently.
   - Compound system failure rate multiplies component failure rates, not averages.
   - Conclusion: cap core components at ~3 (brain AI + executor AI + human); rest as swappable plugins.

3. **"Assembling and hardening a trendy pattern"** (Grok)
   - Plan glues popular patterns (mem0 / AutoGPT / MCP) without a core thesis.
   - Common open-source failure mode: each part trendy, combined effect not 1+1>2.
   - Conclusion: core thesis should be "AI-assisted new PC setup," not "showcase every AI tool."

### Plan Changes

- Cut custom "AI auto-organize + auto-archive" pipeline; use Obsidian plugins (Smart Connections / Copilot).
- mem0 downgraded from "defer" to "do not adopt."
- "Progressive disclosure" explicit: baseline first, advanced on demand.
- Docs: 8 + "Design philosophy" appendix (later merged into overview).

---

## Round 3: Technical Review (Version Compat, Driver Order, Path Conflicts)

### Scope
- Revised 8 docs + design philosophy appendix
- Python environment
- GPU / CUDA setup
- Driver install order
- conda env design

### Key Technical Findings

1. **RTX 5060 is Blackwell sm_120; needs CUDA 12.8 + PyTorch 2.9+** (Opus only)
   - Original "CUDA 12.4 + PyTorch 2.5": `torch.cuda.is_available()` True but `torch.compile` crashes.
   - Correct: `pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128`
   - **Most critical finding across all five rounds**—GPT and Grok missed in rounds 1–2.
   - Details: `05-reference-notes/hardware-compatibility.md`.

2. **Consensus: 3 conda envs enough**
   - Original listed 6 (med / pde / math / nlp / cv / general)—over-segmented.
   - Changed to 3: `med` (medical imaging) / `pde` (numerical PDE) / `math` (pure math + symbolic).
   - Reason: more envs → higher maintenance and cross-env dependency debugging.

3. **Consensus: miniconda3 only, not anaconda3**
   - Old PC: anaconda3 (~20GB) + miniconda3 (empty)—wasted space.
   - New PC: miniconda3; GUI → install `anaconda-navigator` package only.

4. **Consensus: do not migrate old conda envs**
   - Old env paths hard-coded in shebangs; migration breaks envs.
   - Fresh envs on new PC via `environment.yml`.

5. **Driver order: OEM tools → vendor site → Windows Update**
   - Original omitted order; all three noted Windows Update can overwrite site NVIDIA driver.
   - Correct: OEM tools (HP Support Assistant / Lenovo Vantage / Dell SupportAssist) → NVIDIA site → Windows Update (exclude NVIDIA driver).

### Plan Changes

- Document 4 (Python environment) rewritten for CUDA / PyTorch.
- Document 8 adds driver install order.
- New "Hardware compatibility notes" (under 05-reference-notes).
- Document 3 (software list) trims conda-related entries.

---

## Round 4: Execution Review (Will It Run? Where Does It Stick?)

### Scope
- Revised 8 docs + hardware compatibility notes
- End-to-end execution flow
- AI tool roles
- Codex vs Claude Code
- AGENTS.md design

### Key Findings

1. **Codex replaces ~80% of Claude Code**
   - Cost: no Claude Max; deep GitHub integration.
   - 80%: routine codegen / refactor / tests / docs.
   - 20% gap: complex multi-file refactor, long-context reasoning slightly weaker.

2. **All three warn: do not make Codex sole automation hub**
   - All automation through Codex → one API outage / quota / breaking upgrade stops everything.
   - Layered architecture: Codex executor, human / large model brain.
   - Fallback: keep Claude Code as backup executor, switchable.

3. **Trae and Cursor overlap**
   - Opus: pick one to cut maintenance.
   - User kept both: Cursor ecosystem mature; Trae better in Chinese scenarios—complementary.
   - Split: Cursor = brain AI (plan); Trae = executor AI (run).

4. **AGENTS.md two layers**
   - Original: one AGENTS.md per project, lots of duplication.
   - Changed: System layer (cross-project, `~/.config/agents/AGENTS.md`) + Project layer (project root).
   - Project layer: project-specific rules only; no System duplication.

5. **Plan B (apps on C: + data on D:) finalized**
   - Original oscillated between full AppData migration and no migration.
   - Plan B: app binaries on C: defaults; user files / cache / projects on D:.
   - Junction individual app Cache subdirs to D:; do not junction whole user data dirs.

### Plan Changes

- Plan B as official migration strategy.
- "Layered automation": executor runs, brain plans, human decides.
- Document 5 (Skill-MCP) split into "Skill setup" and "MCP setup" (different maintenance cadence).
- Docs: 8 → 9.

---

## Round 5: Detail Review (Commands, Paths, Parameter Semantics)

### Scope
- Revised 9 documents
- All CLI commands
- All path config
- All environment variables

### Key Findings

1. **Cursor `--user-data-dir` is user data, not cache**
   - Original: `--user-data-dir=D:\CursorCache --extensions-dir=D:\CursorCache\ext`—both treated as cache.
   - Actual:
     - `--user-data-dir`: settings.json / keybindings.json / snippets / workspaceStorage → **Dotfiles backup**.
     - `--extensions-dir`: extensions → **disposable cache**.
   - Correct:
     ```
     cursor --user-data-dir=D:\Dotfiles\Cursor --extensions-dir=D:\Cache\Cursor\ext
     ```

2. **Missing uv cache config**
   - Only `PIP_CACHE_DIR`; missing `UV_CACHE_DIR` → uv still wrote to C: default.
   - Add:
     ```powershell
     [Environment]::SetEnvironmentVariable("UV_CACHE_DIR", "D:\Cache\uv", "User")
     ```
   - Also audit poetry / pdm / npm / yarn / pnpm cache vars—configure all at once.

3. **Windows Defender exclusions for critical D: paths**
   - No exclusions → slow D: I/O from real-time scan.
   - Exclude:
     - `D:\Code` (projects)
     - `D:\Datasets` (datasets)
     - `D:\Vault` (Obsidian vault)
     - `D:\conda` (conda envs)
     - `D:\uv` (uv cache)
     - `D:\Cache` (app cache)
   - Command:
     ```powershell
     Add-MpPreference -ExclusionPath "D:\Code","D:\Datasets","D:\Vault","D:\conda","D:\uv","D:\Cache"
     ```

4. **setup-env.ps1 one-shot script**
   - Bundle env vars + Defender exclusions + directory skeleton creation.
   - Run once on new PC for baseline config.
   - Lives under `skill/new-pc-setup-assistant/templates/`.

5. **Junction risks reconfirmed**
   - Junction Cache subdirs only—not whole user data dirs, not credential dirs.
   - `.trae-cn`, `.codex`, `.aws`, `.ssh`, `.gnupg` **stay on C: defaults**.

### Plan Changes

- Document 4 (Python environment) adds `UV_CACHE_DIR`.
- Document 6 (folder architecture) adds Defender exclusion list.
- New `setup-env.ps1` script.
- Document 2 (procedures) fixes Cursor launch parameters.

---

## Five-Round Summary Table

| Round | Theme | Key findings | Most critical | Doc changes |
|-------|-------|--------------|---------------|-------------|
| 1 | Concept | 5 | Drop full AppData migration | 3 rewrites |
| 2 | Philosophy | 3 | Cut custom AI pipeline; progressive disclosure | 1 new (design philosophy) |
| 3 | Technical | 5 | RTX 5060 needs CUDA 12.8 + PyTorch 2.9 | 2 rewrites, 1 new |
| 4 | Execution | 5 | Plan B + layered automation | 1 split, structural changes |
| 5 | Detail | 5 | Cursor params + uv cache | 3 partial edits, 1 new script |

**Total**: 23 key issues across 5 rounds; 3 were "would break install if missed" level (CUDA version / full AppData migration / credential dir junction).

---

## Lessons: Review Prompt Templates

Five rounds produced stable per-round prompts:

### Round 1 (Concept)
> Review the following plan. Answer only: (1) Is it solving a real problem? (2) Are there better alternatives? (3) What should be cut outright? No technical details.

### Round 2 (Philosophy)
> Skip technical details. Philosophically: (1) What is the core thesis? (2) Real problems or new problems? (3) Reinventing wheels others already built?

### Round 3 (Technical)
> Line-by-line technical errors. Focus: (1) version compatibility (CUDA / PyTorch / drivers); (2) path conflicts; (3) command correctness. For each error: location / cause / fix.

### Round 4 (Execution)
> Assume you will execute this plan. (1) Where will it stick? (2) Which assumptions may fail? (3) Is order reasonable? (4) Single points of failure?

### Round 5 (Detail)
> Word-by-word review of commands, paths, parameter names. Confirm each parameter against official docs. For each misread: name / assumed meaning / actual meaning / correct usage.

These five templates are a starting point for any "plan review" project—adapt as needed.
