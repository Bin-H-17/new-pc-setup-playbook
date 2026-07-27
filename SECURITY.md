# Security Policy

## Supported Versions

| Version | Supported          |
|---------|--------------------|
| 1.0.x   | ✅ Security updates |
| < 1.0   | ❌ Not supported   |

## Reporting a Vulnerability

This project ships **PowerShell scripts** that run on the user's old/new Windows PC, including a scanner that reads the registry, AppData metadata, and `~/.ssh` **file names**. Security matters.

If you discover a vulnerability — for example:

- A path that leaks the real username despite the `[USER]` redaction logic
- A scan target that reads sensitive file contents it shouldn't
- Git remotes or credentials appearing unredacted in reports
- A Junction migration step that could destroy user data under edge cases
- Any way the scripts could be tricked into exfiltrating data

**Please report privately** instead of opening a public Issue:

- **Preferred**: GitHub Security Advisory → `Report a vulnerability`
  (Repo → Security → Advisories → New draft advisory)
- **Fallback**: Contact via the maintainer GitHub profile (do **not** paste live secrets)

### Response SLA

- **Acknowledgement**: within 72 hours
- **Initial assessment**: within 7 days
- **Fix or mitigation**: target 30 days, severity-dependent

Please **do not** open a public Issue or PR for unpatched vulnerabilities — give us a chance to fix it first. If a secret was committed elsewhere, **rotate it first**, then discuss history cleanup (`git filter-repo` / BFG).

## What This Project Does NOT Do

For transparency, here is what the scripts in this repo will never do:

- ❌ Upload any scan results, telemetry, or usage data to any server
- ❌ Read the contents of private keys, `.env` files, or credential stores
- ❌ Phone home for update checks (the project has no update mechanism)

Destructive or security-sensitive local actions in `setup-env.ps1` are **opt-in flags** (hibernation off, Defender exclusions, TEMP redirect). Default runs should not perform those.

## Reviewing the Scripts Yourself

All scripts are plain PowerShell with no third-party dependencies and no obfuscation. You are encouraged to read them before running:

- [`skill/new-pc-setup-assistant/templates/scan-old-pc.ps1`](./skill/new-pc-setup-assistant/templates/scan-old-pc.ps1) — old-PC scanner
- [`skill/new-pc-setup-assistant/templates/setup-env.ps1`](./skill/new-pc-setup-assistant/templates/setup-env.ps1) — new-PC environment configurator (`-DryRun` first)
- [`03-operation-templates/Junction-migration-template.ps1`](./03-operation-templates/Junction-migration-template.ps1) — generic Junction migration

Run with `Set-ExecutionPolicy -Scope Process Bypass` so the policy resets when you close the terminal.

## Publishing hygiene

- Never commit `old-pc-scan-report.md`, migration zips, or `.env` (see `.gitignore`).
- Enable GitHub **Secret scanning** + **Push protection** on the public repo.
- CI rejects tracked scan-report filenames when present.
