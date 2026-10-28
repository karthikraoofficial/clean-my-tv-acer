# 05: Debloat in batches

Status: needs-triage
Type: task
Blocked by: 03, 04

Phase 4. For each batch: append it to `artefacts/acer-debloat.txt`, run `disable.ps1`, copy the record, take a screenshot, run the health check, and get the owner's OK. Then sync, wait 15 s, reboot, cold boot, and compare.

## Acceptance
- [ ] B1 telemetry and ad services
- [ ] B2 ads, rows and demo
- [ ] B3 not needed
- [ ] B4 owner choices and discovery extras
- [ ] After a cold boot, `pm list packages -d` matches the applied list, and there's no `RecoveryActivity` in logcat

## Comments
