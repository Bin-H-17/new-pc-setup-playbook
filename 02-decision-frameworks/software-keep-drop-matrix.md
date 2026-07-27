# Software Keep/Drop Matrix

> A new PC is not an excuse to reinstall everything from the old one — use the opportunity to declutter.
> Three-tier classification: Foundation / Furnishing / Defer. Set up the foundation first, add furnishing gradually, defer until needed.

---

## 1. Scan Software Usage on the Old PC

### Method: Read the UserAssist Registry

Windows records execution count and last-run time for each program launched via Explorer, stored at:

```
HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\UserAssist\{GUID}\Count
```

Values are ROT13-encoded and must be decoded before reading.

### Recommended Tools

| Tool | Purpose | Source |
|------|---------|--------|
| **ECmd** (Eric Zimmerman) | Parse UserAssist, output CSV | Official repository |
| **NirSoft UserAssistView** | GUI viewer with export | nirsoft.net |
| **scan-old-pc.ps1** | Project script — one-click 5-dimension scan | `skill/new-pc-setup-assistant/reference/scan-script-notes.md` |

### Key Fields in Scan Output

| Field | Meaning | Use |
|-------|---------|-----|
| Software name | Program display name | Identification |
| Execution count | Cumulative launch count | Frequency assessment |
| Last execution time | Most recent launch | Still in use? |
| Install path | Full exe path | Location |
| File size | Install directory size | Migration cost estimate |

### Frequency Tiers

| Tier | Example Criteria | Decision |
|------|------------------|----------|
| High | ≥ 10 launches in last 30 days | Foundation or Furnishing — must install |
| Medium | 3–10 launches in last 90 days | Furnishing — install as needed |
| Low | 1–2 launches in last 6 months | Defer or drop |
| Dormant | No launch in 6+ months | Drop — reinstall when needed |

---

## 2. Three-Tier Classification Criteria

### 🏗️ Foundation (Day-one essentials)

**Traits**: Everything downstream depends on it. Get it wrong and everything stalls.

| Software | Why it's Foundation |
|----------|---------------------|
| Partitioning / volume labels | Physical basis for data storage |
| GPU / chipset drivers | Prerequisite for hardware to work |
| NVIDIA driver + CUDA | Base for running models — wrong version breaks everything |
| conda / Miniconda | Python environment isolation |
| Python | Runtime for nearly all research tooling |
| Git | Version control + code collaboration |
| SSH | Server access + GitHub push |
| AI tools (IDE class) | All later config flows through these — install immediately after foundation |

### 🛋️ Furnishing (Configure after foundation)

**Traits**: Used daily, but doesn't affect foundation stability — can be installed in batches.

| Software | Why it's Furnishing |
|----------|---------------------|
| Obsidian | Knowledge management — after foundation is solid |
| LaTeX (MiKTeX / TeX Live) | Paper writing — not urgent |
| Browser (Chrome / Edge) | System Edge works in a pinch |
| Social apps (WeChat / QQ / Feishu) | Doesn't block the main workflow |
| Zotero | Reference management — install when needed |
| VS Code (if not using Cursor) | Backup editor |

### ⏸️ Defer (Install when needed)

**Traits**: Scenario-specific; installing early wastes space and background resources.

| Software | Why defer |
|----------|-----------|
| Docker Desktop | Resource-heavy — install when needed |
| WSL2 | Install when Linux programs are required |
| Syncthing | Install when multi-device sync is needed |
| Monitoring dashboards (e.g. Netdata) | Install when troubleshooting |
| VMs (VMware / VirtualBox) | Install when needed |
| Small utilities (Snipaste / Listary, etc.) | Install when needed |

---

## 3. Software Keep/Drop Decision Table Template

Copy this table into your migration checklist:

| Software | Last Used | Frequency | Decision | Install Location | Notes |
|----------|-----------|-----------|----------|------------------|-------|
| Cursor | 2026-07-19 | High | Migrate → Foundation | C: | User data redirected to D: |
| Docker Desktop | 2026-03-12 | Low | Defer | — | Install when needed |
| xxx browser | 2026-01-05 | Dormant | Drop | — | Already have Chrome — redundant |
| WeChat | 2026-07-19 | High | Migrate → Furnishing | C: | File storage moved to D: |
| … | | | | | |

### Field Descriptions

- **Last Used**: Most recent launch time from UserAssist
- **Frequency**: High / Medium / Low / Dormant
- **Decision**: Migrate (Foundation / Furnishing) / Defer / Drop
- **Install Location**: C: / D: / Defer (not installed)
- **Notes**: Migration caveats — cache redirection, config paths, etc.

---

## 4. Common Software Classification Examples (Research-Oriented)

### Foundation

| Software | Install Location | Cache / Data Location |
|----------|------------------|-------------------------|
| Cursor | C: | `D:\Caches\Cursor` + `D:\Dotfiles\Cursor\UserData` |
| Trae | C: | Same structure as above |
| Miniconda / Miniforge | C: | envs at `D:\Environments\conda` |
| Python (system-level) | C: | — |
| Git for Windows | C: | — |
| NVIDIA Driver + CUDA Toolkit | C: | — |

### Furnishing

| Software | Install Location | Cache / Data Location |
|----------|------------------|-------------------------|
| Obsidian | C: | Vault at `D:\Knowledge\Obsidian` or O: |
| MiKTeX / TeX Live | C: | Package cache can move to D: |
| Chrome / Edge | C: | Downloads moved to D: |
| WeChat / QQ / Feishu | C: | File storage moved to D: |
| Zotero | C: | Data directory moved to D: |
| VS Code | C: | User data + extensions moved to D: |

### Defer

| Software | Trigger Condition |
|----------|---------------------|
| Docker Desktop | When containerized services are needed |
| WSL2 | When a Linux environment is needed |
| Syncthing | When multi-device sync is needed |
| Netdata / monitoring dashboards | When diagnosing performance issues |
| VMware / VirtualBox | When VMs are needed |

---

## 5. Duplicate Software Deduplication Principles

### General Rule

**Keep one primary + one backup per category** — more than that raises maintenance cost and scatters caches.

### Browsers

| Primary | Backup | Drop |
|---------|--------|------|
| Chrome | Edge (built-in) | Firefox / Brave / Vivaldi / Opera, etc. |

Rationale: Chrome + Edge cover all scenarios (development + compatibility). Anything else is redundant.

### Editors / IDEs

| Primary | Backup | Drop |
|---------|--------|------|
| Cursor or Trae | VS Code | Sublime / Atom / WebStorm, etc. |

Rationale: AI IDEs already include traditional editor features. One non-AI backup is enough.

### Archive Tools

| Primary | Drop |
|---------|------|
| 7-Zip | WinRAR / Bandizip / others |

Rationale: 7-Zip is open-source, free, ad-free, and handles all formats.

### Terminal

| Primary | Backup |
|---------|--------|
| Windows Terminal | PowerShell 7 |

Rationale: Windows Terminal already provides tabs + profile management.

### Markdown Editors

| Primary | Backup |
|---------|--------|
| Obsidian | Typora (paid, optional) |

Rationale: Obsidian covers both writing and knowledge management.

---

## 6. AI Tool Deduplication Principles

### IDE Class (AI Code Editors)

**Keep 2: primary + backup**

| Role | Recommendation | Purpose |
|------|----------------|---------|
| Primary | Cursor or Trae | Daily development + AI chat |
| Backup | The other one | When primary fails / cross-account scenarios |

Rationale:
- Switching between IDEs is costly (config / shortcuts / extensions)
- But don't rely on just one — AI tools evolve fast and you may need to switch
- More than 2 is wasteful — config sync + scattered caches

### AI Assistant Class (Chat Apps)

**Keep 1**

| Role | Recommendation | Drop |
|------|----------------|------|
| Primary | ChatGPT desktop / Claude desktop | Others |

Rationale: IDEs already cover most AI chat scenarios. Desktop apps are supplementary — keep the one you use most.

### CLI Class (Command-Line AI Executors)

**Keep 1–2: primary + optional backup**

| Role | Recommendation |
|------|----------------|
| Primary | Codex CLI or Trae CLI |
| Backup | The other (for cross-validation) |

### Config Management

| Tool | User Data Location | Extensions / Config Location |
|------|--------------------|------------------------------|
| Cursor | `D:\Dotfiles\Cursor\UserData` | `D:\Caches\Cursor\Extensions` |
| Trae | `D:\Dotfiles\Trae\UserData` | `D:\Caches\Trae\Extensions` |
| VS Code | `D:\Dotfiles\VSCode\UserData` | `D:\Caches\VSCode\Extensions` |

Shortcut launch argument example (Cursor):

```
"C:\Program Files\Cursor\Cursor.exe" --user-data-dir=D:\Dotfiles\Cursor\UserData --extensions-dir=D:\Caches\Cursor\Extensions
```

---

## 7. Deduplication Checklist

- [ ] Browsers: Chrome + Edge only
- [ ] Editors: Cursor/Trae + VS Code only
- [ ] Archive: 7-Zip only
- [ ] Terminal: Windows Terminal only
- [ ] AI IDE: ≤ 2
- [ ] AI assistant: ≤ 1
- [ ] AI CLI: ≤ 2
- [ ] All duplicate software uninstalled
