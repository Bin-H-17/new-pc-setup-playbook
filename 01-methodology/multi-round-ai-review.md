# Multi-Round AI Review Loop: Cross-Model Review of the Same Plan

## 1. Overview

A new PC setup plan is not one document—it is a **hardware-bound, cross-tool, version-sensitive** set of decisions. Any first draft has blind spots: version compatibility, hidden tool traps, architecture-specific requirements.

**Multi-round AI review loop**: Submit the same plan to multiple AIs (Grok / Claude Opus / GPT), each round focused on a different angle, iterate until no AI surfaces **new** issues.

This is not "AI writes the plan" but "AI **finds holes in the plan**." The difference:

| Write mode | Review mode |
|---|---|
| AI produces; human selects | Human produces; AI critiques |
| AI tends to agree with your direction | Prompt forces "do not agree—point out problems" |
| Single AI suffices | Multiple AIs required for cross-check |
| Fast output, many gaps | Slower output, gaps patched repeatedly |

## 2. Why Multiple AIs Are Required

Each AI has **systematic blind spots**—not random errors, but stable tendencies from training data, alignment, and reasoning style:

- **Grok**: Practical engineering angle; sensitive to "will it run"; less sensitive to over-engineering at architecture level
- **Claude Opus**: Deep reasoning; sensitive to "is the architecture sound"; sometimes over-skeptical on simple issues
- **GPT**: Balanced middle ground; sensitive to "are we reinventing wheels"; sometimes stale on latest hardware/version facts

A single AI reviewing its own work **re-confirms its judgments**—more confident, same blind spots. Cross-review: A's blind spot is often B's strength—e.g. Opus alone flagged RTX 5060 as Blackwell sm_120 needing CUDA 12.8; GPT alone flagged "don't make Codex the sole automation hub."

"Multiple" means **different families**, not count. Three GPT variants ≈ one reviewer—overlapping blind spots.

## 3. Five Review Rounds and Their Focus

Do not ask AI to "review everything"—you get shallow lists. **One dimension per round**, dug deep.

### Round 1: Concept Review

**Focus**: Is every concept valid? Are we solving problems that don't exist?

**Typical questions**:
- Is "move AppData to D:" sound? Which AppData subtrees can move vs cannot?
- Is mem0 a real need in your scenario or bandwagon?
- Is "supervisor AI" (AI watching other AIs) over-engineered?

**Output**: Drop pseudo-requirements; keep real concepts.

### Round 2: Philosophy Review

**Focus**: Are we falling into the engineer's three sins—reinventing wheels, maintenance explosion, assembling trendy patterns?

**Typical questions**:
- Is AGENTS.md a low-rent reimplementation of Claude Code?
- Do all 15 MCPs get used? Maintenance cost calculated?
- Is the "AI collaboration workflow" RAG + Agent + MCP + Skill soup when you only need two?

**Output**: Cut designs that look cool but won't be used.

### Round 3: Technical Review

**Focus**: Do hardware, drivers, and version numbers align? Does the compatibility matrix hold?

**Typical questions**:
- RTX 5060 is Blackwell sm_120; PyTorch built with old CUDA (12.4) won't run—need CUDA 12.8+
- PyTorch 2.9+ officially supports sm_120; below that requires custom builds
- conda vs pip mixing conflicts on some packages—need clear boundaries

**Output**: Replace "install latest" with "install this exact version."

> **Key case**: Opus in round 3 alone found RTX 5060 Blackwell sm_120 requires CUDA 12.8 not 12.4. GPT and Grok missed it first pass—consumer Blackwell density in training data is lower. This is cross-review value—single models miss deep technical details.

### Round 4: Implementation Review

**Focus**: Can the plan actually be executed? Any "works on paper, dead on machine" steps?

**Typical questions**:
- Plan says "use Claude Code for automation" but access is restricted in your region—Codex instead?
- "Fully automated scripts" hit UAC and Defender on Windows at step one
- Need **layered automation**: scripts auto at bottom, human confirm mid-layer, human owns top-level direction

> **Key case**: GPT in round 4 said "don't make Codex the only automation hub—layer the architecture." Avoids single point of failure if Codex is down or API changes.

**Output**: Rewrite "ideal plan" into "plan that runs on this machine."

### Round 5: Detail Review

**Focus**: Parameters, paths, registry keys, config syntax—devils live here.

**Typical questions**:
- Cursor `--user-data-dir` vs `--extensions-dir`: user data (settings/keybindings/snippets) vs extension binaries—swapping breaks backup policy
- Windows Defender exclusions need backslashes, no env vars—or rules don't apply
- Wrong conda PATH order lets system Python shadow conda Python

**Output**: Every config line gets a "why written this way" note so future edits don't break it.

## 4. Review Prompt Design Principles

Review quality is ~90% prompt design. Principles from five iterations:

### Principle 1: Full Context

Prompt must include:
- **Hardware**: CPU, GPU (exact model—RTX 5060 not "mid-range NVIDIA"), RAM, disks
- **Domain**: Research area, usual toolchain, typical workloads
- **Requirements**: Problem to solve; costs you won't accept

Without context, AI gives "generic best practice"—often wrong for you. "Install WSL2" is generic; if you state "Windows-native Python + conda, no Linux containers needed," AI should say WSL2 is optional.

### Principle 2: Explicit "Do Not Agree"

Prompt must state:

> Do not agree with my plan. If your first reaction is "looks good," look again—your job is to find problems, not validate. Even one doubt—say it directly.

Without this, default output is "overall reasonable, minor tweaks XYZ"—worthless for review. With it, AI switches to critique mode.

### Principle 3: One Dimension Per Round

Not "review my plan comprehensively." Use "review **only** version compatibility; do not expand other dimensions."

One dimension per round enables depth—e.g. "RTX 5060 is sm_120" won't appear in shallow multi-topic passes.

### Principle 4: Require Objection + Reason

Not just "this is wrong"—"this is wrong because X; change to Y." You judge whether the objection holds; stale training data causes false positives—reasons help you filter.

## 5. Review Prompt Template

Validated template:

```markdown
## Background
- Hardware: [CPU] / [GPU] / [RAM] / [disk layout]
- User: [field] graduate student, research in [topic]
- Goal: [one sentence]
- Unacceptable costs: [e.g. "reinstall OS" / "lose existing conda env"]

## Current Plan
[Paste current plan document]

## This Round's Focus
This round reviews [dimension name] only—do not expand other dimensions.

## Review Requirements
1. Do not agree with the plan. Find problems, do not confirm.
2. Each issue: problem + reason + suggested fix.
3. If a point is genuinely fine, do not invent issues.
4. If uncertain, say "uncertain"—do not guess.
5. Sort by severity: most fatal first.
```

## 6. Termination Criteria

Review is not infinite. Stop when:

1. All three AIs in one round raise **no new issues**—only repeat prior findings
2. New issues are detail-only (typos, wording)—not structural
3. You can explain every decision: why this way, what happens if not

Usually 4–6 rounds reach this. If major issues still appear at round 10, the plan direction is wrong—return to round 1 concept review.

## 7. Why It Works

### 1. Non-Overlapping Blind Spots

Single AI spins in its blind spots reviewing its own work. Cross-review: A covered by B, B by C—fewer holes than any one reviewer.

### 2. One Dimension Per Round

"Full review" = shallow everywhere. One dimension → depth like "RTX 5060 is sm_120"—invisible in shallow passes.

### 3. Forced Non-Agreement

Default alignment favors helping you succeed—which in review means **stopping you from doing the wrong thing**. Explicit non-agreement switches mode.

### 4. Multiple Rounds Not One

Round 1: surface; round 3: deep; round 5: details. One round only catches surface.

## 8. Common Pitfalls

### Pitfall 1: Same AI, Multiple Rounds

Same family reviewing draft 1, 2, 3 loops in the same blind spots. Must rotate **different families**.

### Pitfall 2: Vague Review Dimension

"Review my plan" → shallow laundry list. Each round: "version compatibility only" or "architecture only."

### Pitfall 3: Accept Every Comment Blindly

AIs err too—especially stale training data. Judge each item; that's why you require reason + suggested fix.

### Pitfall 4: Review Without Updating the Plan

Value is iteration. After each round, update the doc; next round reviews the **updated** version. Same doc reviewed ten times adds nothing.

## 9. Summary

Multi-round AI review treats **AIs as engineers with different blind spots, forced to critique each other** until holes surface. Not "AI writes the plan"—"AI **stops you from stupid irreversible mistakes**."

For new PC setup—hardware + software + versions tightly coupled, many decisions irreversible—the ROI is high: five rounds of review vs weeks of rework later.
