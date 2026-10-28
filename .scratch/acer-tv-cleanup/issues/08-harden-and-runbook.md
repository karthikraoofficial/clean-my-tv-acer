# 08: Close ADB and write the runbook

Status: needs-triage
Type: task
Blocked by: 07

Phase 7.

## Acceptance
- [ ] Wireless debugging port noted, then Wireless, Network and USB debugging off; authorisations revoked; laptop removed from Paired devices
- [ ] `adb-closed.py 192.168.1.162 <wireless port>` exits 0 before the reboot
- [ ] After the reboot, `adb-closed.py 192.168.1.162` exits 0
- [ ] `RUNBOOK.md`: what was disabled and why, the one-line restore (`-Stock com.google.android.apps.tv.launcherx`), the after-update check, re-enabling debugging, changing the dock
- [ ] PRD closed; CONTEXT, ADRs, CLAUDE.md and README checked against what happened

## Comments
