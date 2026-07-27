# Contributing to New PC Setup Playbook

Thanks for considering a contribution! This project aims to be a **reproducible engineering methodology** for PC setup, not a one-person blog.

## Before You Start

Please **open an Issue first** before sending a PR.

## Project Scope

**In scope**:

- Improvements to the four methodologies (Three-Layer Classification / Plan B / Progressive Disclosure / Multi-round AI Review)
- New decision frameworks
- Bug fixes and tests for PowerShell scripts
- Translations (Chinese / others) as optional additions
- Real-world post-mortems
- Hardware compatibility notes

**Out of scope**:

- Replacing PowerShell with Bash/Python as the primary target
- Telemetry / phone-home
- Bundling third-party installers or binaries
- Vendor marketing copy

## Development Setup

```powershell
git clone https://github.com/Bin-H-17/new-pc-setup-playbook.git
cd new-pc-setup-playbook

Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\skill\new-pc-setup-assistant\templates\scan-old-pc.ps1

.\skill\new-pc-setup-assistant\templates\setup-env.ps1 -DryRun -DataDrive D:
```

No build step. No dependencies. Pure Markdown + PowerShell.

## Contribution Types

### Bug Reports

Include OS / `$PSVersionTable`, exact commands, expected vs actual, and **redacted** report snippets only.

### Script Fixes

- Keep PowerShell 5.1 compatibility
- `#Requires -Version 5.1`
- No third-party module dependencies
- Update [`scan-script-notes.md`](./skill/new-pc-setup-assistant/reference/scan-script-notes.md) when adding scan dimensions

### Doc Improvements

Docs are CC BY 4.0. For new methodology articles, follow `01-methodology/` (problem → principle → practice → pitfalls).

### Post-mortems

Add under `04-retrospectives/` with anonymized hardware, timeline, root cause, and takeaway. No real usernames or serials.

## PR Checklist

- [ ] Issue discussed first
- [ ] No real usernames, secrets, or scan reports committed
- [ ] PowerShell 5.1 tested if scripts changed
- [ ] Docs updated with script changes
- [ ] Licenses unchanged unless discussed
- [ ] No new third-party dependencies without discussion

## License of contributions

By contributing, you agree your contributions are licensed under:

- **MIT** for code (scripts, templates)
- **CC BY 4.0** for documentation

See [LICENSE](./LICENSE) and [LICENSE-docs](./LICENSE-docs).
