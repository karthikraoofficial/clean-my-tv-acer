# 05: Debloat in batches

Status: needs-triage
Type: task
Blocked by: 03, 04

Phase 4. For each batch: append it to `artefacts/acer-debloat.txt`, run `disable.ps1`, copy the record, take a screenshot, run the health check, and get the owner's OK. Then sync, wait 15 s, reboot, cold boot, and compare.

## Acceptance
- [ ] B1 ad services and telemetry (6)
- [ ] B2 ad-click service and unused features (4)
- [ ] _(Updated: B3/B4 dropped for the R4G, ADR 0004)_
- [ ] After a **cold boot** (power cable out 30 s), `check.py artefactscer-debloat.txt` reports no drift. Any [?] package that came back is re-enabled, removed from the applied list, and noted in the list header.
- [ ] No `RecoveryActivity` in logcat; launcherx still owns Home

## Comments
