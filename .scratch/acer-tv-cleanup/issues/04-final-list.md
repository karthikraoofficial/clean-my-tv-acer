# 04: Final debloat list approved

Status: resolved
Type: task
Blocked by: 02

Phase 3. `artefacts/acer-debloat-final.txt` = the AR55 list + discovery − must-keep packages + the owner's answers, in batch sections of 10 or fewer. _(Updated 2026-10-28)_ Draft v2 is ready for the R4G: 10 packages (B1 6, B2 4), only ones that persist or are still to be verified (ADR 0004). Waiting on the owner's approval.

## Acceptance
- [x] Every entry exists on this TV (`pm list packages`, discovery 2026-10-28)
- [x] No must-keep package, no core package, no Home owner, no factory package
- [x] No package the R4G firmware re-enables at cold boot (`docs/devices/acer-r4g.md`)
- [x] Owner approves the file (2026-10-28)

## Comments

**2026-10-28, closed.** The owner replied "approve" to draft v2. The header now reads APPROVED v2.
