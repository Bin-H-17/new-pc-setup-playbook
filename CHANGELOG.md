# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Repository language standardized to **English** (paths, docs, skill, scripts, README)
- Renamed folders: `01-methodology`, `02-decision-frameworks`, `03-operation-templates`, `04-retrospectives`, `05-reference-notes`
- Open-source hardening: `PRIOR_ART.md`, `REFERENCES.md`, `NOTICE`, CI guard for scan reports
- `SKILL.md`: YAML frontmatter; English paths
- `scan-old-pc.ps1`: English report `old-pc-scan-report.md`; redact git username; strip remote credentials
- `setup-env.ps1`: destructive actions opt-in; `-DryRun`
- GitHub owner links: `Bin-H-17`

### Planned
- Screenshot for README
- Star History badge
- Skill auto-trigger test cases

## [1.0.0] — 2026-07-20

### Added

#### Methodology (4 articles)
- Three-Layer Classification
- Plan B Drive Strategy
- Progressive Disclosure
- Multi-Round AI Review

#### Decision Frameworks (4 tools)
- Partition decision tree
- Software keep/drop matrix
- Cache migration table
- AI tool division matrix

#### Operation Templates
- `Junction-migration-template.ps1` (formerly Chinese-named template): Move-AppDataToJunction + Restore-Junction

#### Post-mortems (3 articles)
- Timeline, Pitfalls, If I Did It Again

#### References
- Hardware compatibility notes
- Distilled AI review insights

#### Skill (`new-pc-setup-assistant`)
- `SKILL.md`, `reference/decision-flow.md`, `reference/scan-script-notes.md`
- `templates/scan-old-pc.ps1`, `setup-env.ps1`, `startup-guide-template.md`

#### Project Meta
- Dual license MIT + CC BY 4.0, CONTRIBUTING, CODE_OF_CONDUCT, SECURITY, CITATION.cff, CHANGELOG

### Privacy & Anonymization
- Paths use `[USER]` / `[REDACTED]`
- Scanner does not read private keys, `.env`, or credential stores; no upload

### Known Limitations
- Windows-only (PowerShell)
- PowerShell 5.1+ (7 recommended)
- Some scan dimensions need admin
- Junction caveats for some Electron apps — see `04-retrospectives/pitfalls.md`

[Unreleased]: https://github.com/Bin-H-17/new-pc-setup-playbook/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/Bin-H-17/new-pc-setup-playbook/releases/tag/v1.0.0
