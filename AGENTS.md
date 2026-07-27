# AGENTS.md — AI collaboration boundaries

This file defines what an AI agent (planner or executor) **may do automatically** vs **must stop and ask the human** when using this playbook.

It is a policy document, not a sandbox. Agents without OS-level restrictions can still ignore it — humans must keep high-risk scripts under review.

## Roles

| Role | Typical tools | Allowed without extra confirmation |
|------|---------------|--------------------------------------|
| Planner (“brain”) | Chat / skill | Ask questions, draft plans, write Markdown plans, generate script *parameters* |
| Executor (“hands”) | Shell / IDE agent | Read files, run **DryRun**, install user-approved apps, edit non-system configs the user named |

## Must stop and ask (non-negotiable)

Before doing any of the following, the agent **must** get an explicit human yes for *this* machine and *this* path:

1. Delete, move, or replace user data directories
2. Create or remove NTFS Junctions / reparse points
3. Change user or machine environment variables (except when the user already approved a specific `setup-env.ps1` flag set)
4. Disable hibernation, change power plans, or add Defender exclusions
5. Run scripts elevated / as Administrator
6. Write to the registry, change drivers, or touch BIOS/UEFI settings
7. Commit or upload `old-pc-scan-report.md`, migration zips, `.env`, SSH keys, or credential files
8. Install software the user did not list in the current plan
9. Anything irreversible if wrong (disk partitioning, format, wiping)

If unsure, treat it as “must ask.”

## Allowed with low ceremony

- Drafting / editing plan Markdown the user requested
- Running `scan-old-pc.ps1` **after** the user agrees to a local scan
- Running `setup-env.ps1 -DryRun ...` or `Junction-migration-template.ps1 ... -DryRun`
- Looking up public docs (PyTorch/CUDA install pages, etc.)
- Suggesting redactionsactions summaries of scan reports (never paste raw secrets)

## Required sequence for high-risk scripts

1. Show the exact command line
2. Run **`-DryRun`** (or equivalent preview) first
3. Show preview output to the human
4. Require an explicit confirm flag / typed confirmation for the live run
5. On failure: stop; do not invent recovery steps that delete more data without asking

## Audit notes (lightweight)

When an executor finishes a high-risk step, append one line to the user’s `progress.md` (or ask them to):

```text
[YYYY-MM-DD HH:mm] OK|FAIL junction|setup-env | paths=... | dryrun=no | confirmed_by=user
```

## Enterprise / managed devices

On corporate or MDM-managed PCs: **do not** run elevated playbook scripts unless IT/security approved. Prefer exporting plans only; leave execution to approved channels.
