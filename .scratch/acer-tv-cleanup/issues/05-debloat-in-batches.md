# 05: Debloat in batches

Status: resolved
Type: task
Blocked by: 03, 04

Phase 4. For each batch: append it to `artefacts/acer-debloat.txt`, run `disable.ps1`, copy the record, take a screenshot, run the health check, and get the owner's OK. Then sync, wait 15 s, reboot, cold boot, and compare.

## Acceptance
- [x] B1 ad services and telemetry (6)
- [x] B2 ad-click service and unused features (4)
- [x] _(Updated: B3/B4 dropped for the R4G, ADR 0004)_
- [x] After a **cold boot** (power cable out 30 s), `check.py artefactscer-debloat.txt` reports no drift. Any [?] package that came back is re-enabled, removed from the applied list, and noted in the list header.
- [x] No `RecoveryActivity` in logcat; launcherx still owns Home

## Comments

**2026-10-28: both batches applied, waiting on the owner's cold boot.**
- B1: `disable.ps1` disabled 6, all `disabled-user`. Health check with Netflix: ALL PASSED. Play Store loaded signed in (`shots/B1-*.png`, `logs/B1-*.log`).
- B2: 4 names were appended; `disable.ps1` added them to the same record and disabled them. Health check with Prime Video: ALL PASSED (`shots/B2-*.png`, `logs/B2-*.log`).
- `sync`, then 15 s. Next: the owner pulls the power cable for 30 s, then `check.py`.

**2026-10-28, closed after the cold boot.** The owner pulled the power for 30 s; uptime afterwards was 146 s.
- `check.py`: 9 of 10 still disabled; `com.google.android.partnersetup` was back on, re-enabled by the firmware's boot job. Per ADR 0004 it was **dropped**: commented out in both lists and noted in the header. The restore record still has it as "enabled before", which is harmless.
- After the drop: `check.py` reports "nothing drifted: 9 listed packages are still disabled", exit 0.
- Home is launcherx; there's no `RecoveryActivity` in logcat; setupwraith and launcherx are enabled; port 5555 came back by itself.
- Health check CB1 with JioHotstar: ALL PASSED. Logs: `coldboot1-check*.log`, `CB1-health.log`.
