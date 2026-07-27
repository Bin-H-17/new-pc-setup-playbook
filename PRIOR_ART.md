# Prior Art & Overlap Check

**Check date:** 2026-07-27 (Asia/Shanghai)  
**Scope:** Public GitHub / web search for Windows PC-setup playbooks, migration checklists, and agent skills with similar scope.  
**Method:** Web search; comparison against common checklist repos. `gh` CLI not authenticated for deep code search.

## Verdict

**Feasible to publish.** Closest public materials are **human checklists** or **vendor-specific howtos**, not an AI-agent skill + Plan B / Junction + multi-round review methodology pack for Windows workstations.

This repo is a **methodology + local PowerShell toolchain + agent skill**, not a claim to invent NTFS junctions or “install Git first.”

## Closest / related (not duplicates)

| Project / practice | Overlap | Difference |
|--------------------|---------|------------|
| Generic “new PC checklist” repos (e.g. Windows reinstall checklists) | Ordered install steps | No agent skill, no scan→plan pipeline, no Junction Plan B |
| OEM / laptop howtos (MSI, etc.) | Driver / first-boot notes | Hardware-specific; not reusable methodology |
| NTFS junction documentation (`mklink /J`) | Junction technique | Technique only; this repo wraps policy + scripts + skill |
| Agent skill install guides that mention junctions | Junctions for skill paths | Different problem (skill discovery), not PC migration |

## Positioning (honest)

| We package | We do **not** claim |
|------------|---------------------|
| Three-layer install priority, Plan B disk strategy, progressive disclosure, multi-round AI review | Inventing junctions, conda, or Windows setup |
| Local-only scanner + env/junction templates | A managed MDM / enterprise imaging product |
| Trae/Cursor-oriented skill workflow | Affiliation with ByteDance / Trae / Cursor vendors |

See [REFERENCES.md](REFERENCES.md) and [NOTICE](NOTICE).
