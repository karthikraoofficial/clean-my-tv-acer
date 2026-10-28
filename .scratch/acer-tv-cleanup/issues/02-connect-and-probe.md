# 02: Connect and probe

Status: needs-info
Type: task
Blocked by: 01

Phase 1. Needs the owner at the TV: Wireless debugging pairing code and ports, then "Allow USB debugging?" with "Always allow" ticked.

## Acceptance
- [x] `tv.py --probe` answers on 192.168.1.162:5555
- [x] Model, device, fingerprint, SDK and build saved to `artefacts/lists/identity.txt`
- [ ] **Gate:** device `R4` with `tvlauncher` and no `launcherx` → continue. `R4_GTV` or `launcherx` → STOP and re-plan (owner's decision).
- [ ] Discovery saved: all packages, third-party, HOME claimants and owner, Wi-Fi owner, `privacy.py` report and candidates
- [ ] Unknown packages explained with `dumpsys package` (never started)

## Comments

**2026-10-28: the gate stopped us. This is the Google TV variant.**
- Connection: Wireless debugging pairing on 38299 failed ("protocol fault"; the dialog had closed), but `adb mdns services` showed `_adb._tcp` on 5555, which was now open. `tv.py` connected directly and the owner accepted the key.
- Identity: model `R4G`, device `R4_GTV`, manufacturer MOKA, Android 14 / SDK 34, build `UKR1.260308`, fingerprint `ACER/ACER_NFF/R4_GTV:14/UKR1.260308/5597:user/release-keys`, patch 2026-04-05. This is **identical** to upstream `docs/devices/acer-r4g.md`.
- Home owner: `com.google.android.apps.tv.launcherx/.home.HomeActivity`. Other HOME claimants: setupwraith `.RecoveryActivity` (priority 1) and `com.android.tv.settings/.system.FallbackHome`.
- setupwraith owns a saved Wi-Fi network (`cname=com.google.android.tungsten.setupwraith`), so it must stay enabled.
- Already disabled before we started: `com.android.dreams.basic`.
- Upstream #1121 (merged 2026-10-23) made `stock_home_redirect` cover a stock home that is on screen at boot or after Home. It does not cover returning from an HDMI input.
- Per the owner's decision, execution stopped here. Nothing was changed on the TV; only read-only queries ran. Waiting on the owner's choice of re-plan.
