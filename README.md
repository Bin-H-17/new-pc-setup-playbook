# New PC Setup Playbook

> An AI-assisted methodology + automation toolchain for configuring a new Windows PC — turning machine setup from manual labor into reproducible engineering practice.

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Docs: CC BY 4.0](https://img.shields.io/badge/Docs-CC_BY_4.0-blue.svg)
![Platform: Windows 11](https://img.shields.io/badge/Platform-Windows_11-0078D4.svg)
![Skill: Trae](https://img.shields.io/badge/Skill-Trae-orange.svg)
![Stars](https://img.shields.io/github/stars/Bin-H-17/new-pc-setup-playbook)
![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)

---

## What This Is

This is **not another software install list.** It is a structured, reviewable, evolving methodology that uses AI as both your **configuration brain** and **executor** — turning each PC setup into a reusable asset.

## Why This Project Exists

- **Tedious**: OS, software, environment, data migration — easily a full day
- **Easy to miss things**: discover a missing config a month later
- **Compounds over time**: C drive fills up; directories get messier
- **Repetitive**: redo everything on every new PC
- **Decision fatigue**: which version, which drive, Junction or not?

**Conclusion**: PC setup is an engineering problem. This project treats it as one.

## Core Features

### 1. Three-Layer Classification

| Layer | Meaning | When |
|-------|---------|------|
| Foundation | Without it, nothing else works | Day 0 |
| Finishing | Tools that make daily work fly | Day 1-3 |
| Deferred | Nice-to-have | As needed |

### 2. Plan B (Drive Strategy)

**Install apps on C, store data/caches on D** — connected via Junction links.

### 3. Progressive Disclosure (AI Collaboration)

- **AI Brain** (`new-pc-setup-assistant` skill): asks, plans, decides, generates schemes
- **AI Executor** (Claude / GPT / Grok / etc.): runs scripts, writes files, does the work

### 4. Multi-Round AI Review

Cross-model review for logic, safety (Junctions/permissions), then refinement.

## Quick Start

### Step 1 — Install the Skill

Copy `skill/new-pc-setup-assistant/` into your agent skills path (Trae / Cursor / compatible), or follow [`skill/new-pc-setup-assistant/SKILL.md`](./skill/new-pc-setup-assistant/SKILL.md).

### Step 2 — Scan Your Old PC

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\skill\new-pc-setup-assistant\templates\scan-old-pc.ps1
```

Generates `old-pc-scan-report.md` (software usage, caches, environment, repos, SSH file names). Review before sharing; do not commit it.

### Step 3 — Generate Your Plan

Chat with the skill, then follow prompts to produce your tailored plan and scripts.

```powershell
.\skill\new-pc-setup-assistant\templates\setup-env.ps1 -DryRun -DataDrive D:
```

## Directory Structure

```
new-pc-setup-playbook/
├── README.md
├── LICENSE / LICENSE-docs
├── CONTRIBUTING.md / CODE_OF_CONDUCT.md / SECURITY.md / CHANGELOG.md
├── CITATION.cff / NOTICE / PRIOR_ART.md / REFERENCES.md
├── .gitignore / .github/workflows/
├── 01-methodology/
├── 02-decision-frameworks/
├── 03-operation-templates/Junction-migration-template.ps1
├── 04-retrospectives/
├── 05-reference-notes/
└── skill/new-pc-setup-assistant/
```

See folders for full article lists. Key entry points:

- [Three-Layer Classification](./01-methodology/three-layer-classification.md)
- [Plan B Strategy](./01-methodology/plan-b-strategy.md)
- [Progressive Disclosure](./01-methodology/progressive-disclosure.md)
- [Multi-Round AI Review](./01-methodology/multi-round-ai-review.md)
- [Junction migration template](./03-operation-templates/Junction-migration-template.ps1)

## Requirements

- Windows 11 (some scripts work on Windows 10)
- PowerShell 5.1+ (7 recommended)
- Optional: Trae / Cursor / other skill-compatible agents

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

- **Code**: [MIT](./LICENSE)
- **Docs**: [CC BY 4.0](./LICENSE-docs)

Attribution: [NOTICE](./NOTICE) · [PRIOR_ART.md](./PRIOR_ART.md) · [REFERENCES.md](./REFERENCES.md)

## Disclaimer

Software and docs are provided **AS IS**, without warranty of any kind. Authors are not liable for damages arising from use (including Junction moves, environment changes, Defender exclusions, etc.).

## Contact

https://github.com/Bin-H-17/new-pc-setup-playbook/issues