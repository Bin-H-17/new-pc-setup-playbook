# Three-Layer Classification: A Priority Framework for New PC Setup

## 1. Problem Background

When a new PC arrives, AI-assisted setup checklists easily balloon to hundreds of items: disk partitioning, drivers, conda, Git, SSH, Cursor, Trae, Codex, Obsidian, LaTeX, Syncthing, mem0, Docker, WSL2… Faced with that list, two extreme reactions are most common:

1. **Install everything**: Set up every tool you might ever need in one go, then get stuck in a deep rabbit hole for three days while the basics never come online.
2. **Install as you go**: Plan nothing upfront, install when needed, then discover that some "foundation-level" decisions were already locked in by earlier ad-hoc choices—with no way back.

Both extremes share the same tension: **limited energy vs. a massive todo list**. The core purpose of the three-layer classification is to reorder that list by **cost of change later**, so limited energy goes first to decisions that are hard or impossible to undo.

## 2. Definition of the Three Layers

### 1. True Foundation (Irreversible Layer)

**Definition**: Decisions that, once made, are extremely costly to change later—sometimes requiring a full OS reinstall to fix.

**Criteria**:
- Change affects dependencies across multiple installed applications
- Change requires re-downloading tens of GB of data
- Change invalidates paths for all existing projects
- Change breaks environments that have already been tuned

**Typical examples**:

| Item | Why it is true foundation |
|---|---|
| Disk partitioning scheme | Once C: space is allocated, shrinking/expanding later carries data-loss risk |
| NVIDIA driver + CUDA version | Tightly bound to GPU architecture; RTX 5060 is Blackwell sm_120 and requires CUDA 12.8+ |
| conda environment directory | All Python projects depend on this path; migration means reinstalling all dependencies |
| Git + SSH keys | Global identity configuration; affects commit identity across all repositories |
| AI tool configuration (Cursor/Trae/Codex) | Involves launch args, user data directories, MCP/Skill registration; AI workflows depend on it once set |
| AGENTS.md | The "constitution" for multi-AI collaboration; once set, all AIs follow it |
| Windows user directory structure | Once Documents/Desktop/Downloads paths are occupied by default installs, migration is painful |

### 2. Fit-Out (Adjustable Layer)

**Definition**: Decisions that work once made, but can be changed later at the cost of redoing that project only—not the rest of the system.

**Criteria**:
- Change affects only a single tool's internal state
- Change has export/import mechanisms
- Failure means delete and redo

**Typical examples**:

| Item | Why it is fit-out |
|---|---|
| Obsidian vault structure | Note folders can be reorganized anytime; markdown files themselves stay intact |
| AI tool plugin configuration | Plugins can be installed/uninstalled anytime; settings.json can be version-controlled |
| LaTeX templates | `.tex` files can be edited anytime; does not affect the compiler |
| Browser configuration (bookmarks/extensions/search engines) | Browsers sync via accounts; reinstall restores state |
| Social app file storage paths | WeChat/QQ/Feishu storage paths can be changed in app settings; official migration tools exist |
| VSCode/Cursor keybindings.json | Config files can be changed anytime |

### 3. Defer (Install When Needed Layer)

**Definition**: Items you are not sure you need yet, or whose use case has not appeared. Forcing setup now is "performative" and steals energy from true foundation work.

**Criteria**:
- No clear deadline of "must use by day N"
- Setup requires a prerequisite (e.g. Syncthing needs a second machine first)
- If unused for three months after install, configuration goes stale (driver versions, API keys, etc.)

**Typical examples**:

| Item | Why defer |
|---|---|
| mem0 (long-term memory system) | Integrate after AI workflows stabilize; otherwise you keep tuning interfaces |
| qmd (Quarto markdown) | Install when you actually need cross-format reports |
| Syncthing dual-machine sync | Configure when the second machine arrives |
| Monitoring dashboards (Grafana/Netdata) | Add when training workloads hit performance bottlenecks |
| Docker / WSL2 | Install when you have a concrete need for Linux containers |
| Domain-specific tools (e.g. certain simulation software) | Install when needed; early install is just comfort |

## 3. Core Criterion: Cost of Change Later

When sorting todos into these three buckets, the only reliable criterion is **cost of change later**:

> - **Cannot change** → True foundation
> - **Can change** → Fit-out
> - **Unsure whether change is needed** → Defer

Note: this is not "importance" and not "difficulty." Some items matter a lot but are easy to change (e.g. Git username)—those are fit-out. Some items are not hard but hard to undo (e.g. disk partitioning)—those are true foundation.

In gray areas, ask: **"If I want to change this decision in three months, how much time will it take?"**
- Answer is "reinstall OS" or "reinstall all dependencies" → True foundation
- Answer is "redo this one project" → Fit-out
- Answer is "not sure I'll still use it" → Defer

## 4. Two Pain Points It Solves

### Pain Point 1: "Install Everything" Anxiety

The longer the list, the more anxious you get—every item feels like "I might need this later." Three-layer classification forces one question first: **Is this true foundation? If not, can it wait until I actually need it?**

About 90% of "install everything" is fit-out and defer items mistaken for true foundation. Moving them out of week-one work shrinks the list to something executable.

### Pain Point 2: "Set Up Fully vs. Install As You Go"

The "set up fully" camp wants everything configured upfront; the "install as you go" camp waits until needed. Both have merit, but neither distinguishes **what** is being installed.

The three-layer answer:
- **True foundation must be set up fully**—because it cannot be changed later; decide on day one.
- **Fit-out can go either way**—your choice; it is reversible.
- **Defer is always install-as-you-go**—early install only adds maintenance burden.

The "set up fully vs. install as you go" debate disappears: **true foundation fully, defer as-you-go, fit-out your choice.**

## 5. Why This Method Works

### 1. Focus Energy on Irreversible Decisions

Day-one energy is scarce. Spending it on "Obsidian theme configuration" means no energy left when you discover conda was installed on the wrong drive. Three-layer classification locks day-one energy on true foundation.

### 2. Avoid Wasting Context on Deferred Items

During AI-assisted setup, each deferred item consumes context window and review rounds. Removing them from week-one frees AI attention for true foundation—"defer" is not "abandon," but "let AI handle it when needed."

### 3. Leave Room for Error in Fit-Out

Once true foundation is set, fit-out has a stable base to experiment on. Obsidian structure can change daily; conda environments are unaffected. "Stable foundation + flexible fit-out" is what lets beginners iterate workflows quickly.

### 4. Makes the "AI Collaboration Constitution" Writable

Without three-layer classification, AGENTS.md cannot say "when must you stop and ask the user." With it, AGENTS.md can state directly:

> For true foundation decisions (disk/CUDA/conda path/SSH keys), stop and wait for user confirmation; for fit-out decisions, try on your own and record in progress.md; for defer items, skip entirely.

That makes AI autonomy boundaries explicit and prevents unilateral action on irreversible decisions.

## 6. How It Differs from Other Classifications

Common alternatives:

- **By importance**: important/unimportant/urgent. Problem: importance is subjective and does not map cleanly to "when to do it."
- **By difficulty**: easy/medium/hard. Problem: hard ≠ irreversible; easy ≠ reversible.
- **By software type**: system/dev/productivity. Problem: same category can span all three layers.

Three-layer classification aligns with the practical question **when to do it and whether it can be changed**, not abstract attributes. That is why it works better for new PC setup than generic schemes.

## 7. Usage Recommendations

1. **Week one: true foundation only.** Move fit-out and defer to later weeks.
2. **True foundation list: no more than 10 items.** More than 10 usually means criteria are too loose and fit-out slipped in.
3. **Write defer items on the list but do not execute.** The list is for future recall, not immediate action.
4. **Review layer assignment weekly.** Some defer items upgrade to true foundation as workflows evolve (e.g. once training starts, CUDA version moves from fit-out to true foundation).
5. **Document three-layer criteria in AGENTS.md.** So AI applies the same priority rules during execution.

Three-layer classification is not a static checklist—it is a **dynamic priority framework**. It answers not "what to install" but **what first, what later, and when**. In new PC setup with hundreds of interdependent todos, this framework turns chaos into an executable order.
