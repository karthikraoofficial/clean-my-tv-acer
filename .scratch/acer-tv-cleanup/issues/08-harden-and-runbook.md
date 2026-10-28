# 08: Close ADB and write the runbook

Status: resolved
Type: task
Blocked by: 07

Phase 7.

## Acceptance
- [x] Wireless debugging port noted, then Wireless, Network and USB debugging off; authorisations revoked; laptop removed from Paired devices
- [x] `adb-closed.py 192.168.1.162 <wireless port>` exits 0 before the reboot
- [x] After the reboot, `adb-closed.py 192.168.1.162` exits 0
- [x] `RUNBOOK.md`: what was disabled and why, the one-line restore (`-Stock com.google.android.apps.tv.launcherx`), the after-update check, re-enabling debugging, changing the dock
- [x] PRD closed; CONTEXT, ADRs, CLAUDE.md and README checked against what happened

## Comments

**2026-10-28, closed.**
- Wireless debugging had already switched off at the ticket-07 reboot (mdns showed only `_adb._tcp` 5555), so there was no separate TLS port to check.
- The owner turned USB debugging and the network toggle off, revoked authorisations, and restarted the TV.
- `adb-closed.py 192.168.1.162` → "192.168.1.162:5555 is closed: the TV refused the connection", exit 0 (`logs/adb-closed.log`). The TV still answers ping, and mdns lists nothing. The laptop's adb server was stopped.
- RUNBOOK.md: what was disabled and why, the one-line restore (`-Stock com.google.android.apps.tv.launcherx`), the after-update check/--fix, helper recovery, changing the dock, and re-enabling debugging.
