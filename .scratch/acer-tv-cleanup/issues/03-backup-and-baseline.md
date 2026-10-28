# 03: Backup and health-check baseline

Status: in-progress
Type: task
Blocked by: 02

Phase 2.

## Acceptance
- [x] `artefacts/backup/`: disabled-before, enabled-before, getprop, settings (global/secure/system), display
- [x] `artefacts/shots/00-before-home.png`
- [x] `health-check.ps1` proven red (bogus must-keep package) and then green on the untouched TV
- [ ] Restore record written (waits on the list approval in 04) by `recovery.py --save artefacts/acer-debloat.txt` and copied to `artefacts/records/`

## Comments

**2026-10-28: backups and baseline done.**
- `artefacts/backup/`: enabled-before (162), disabled-before (only `com.android.dreams.basic`), packages-all-uid, getprop, settings global/secure/system, display, a11y-dns. Private DNS is unset; no accessibility services are enabled.
- The "before" screenshot shows the stock Google TV home with a sponsored "Recommended For You" hero and "Top picks" rows.
- Health check: red (`-ExtraMustKeep com.example.bogus`) → 1 FAILED, only the bogus package. Green baseline → ALL PASSED (Home = launcherx, Play Store and YouTube open). Logs are in `artefacts/logs/T03-health-*.log`.
- The first run showed a bug in the check itself: PowerShell 5.1 strips inner double quotes from native arguments, so the `grep -E` pattern broke. Fixed by single-quoting it for the TV's shell.
- Found: a second user profile exists (user 10, "new_user"). JioCinema is installed only there. All work is on user 0, and user 10 is untouched.
