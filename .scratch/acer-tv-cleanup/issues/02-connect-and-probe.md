# 02: Connect and probe

Status: ready-for-human
Type: task
Blocked by: 01

Phase 1. Needs the owner at the TV: Wireless debugging pairing code and ports, then "Allow USB debugging?" with "Always allow" ticked.

## Acceptance
- [ ] `tv.py --probe` answers on 192.168.1.162:5555
- [ ] Model, device, fingerprint, SDK and build saved to `artefacts/lists/identity.txt`
- [ ] **Gate:** device `R4` with `tvlauncher` and no `launcherx` → continue. `R4_GTV` or `launcherx` → STOP and re-plan (owner's decision).
- [ ] Discovery saved: all packages, third-party, HOME claimants and owner, Wi-Fi owner, `privacy.py` report and candidates
- [ ] Unknown packages explained with `dumpsys package` (never started)

## Comments
