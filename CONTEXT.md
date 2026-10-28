# CONTEXT: Clean My TV (Acer)

Terms used in the plan, tickets, scripts and runbook.

| Term | Meaning |
|---|---|
| **Debloat** | Turning packages off with `pm disable-user --user 0`. Never uninstalling. Undone with `pm enable` or `restore.ps1`. |
| **Approved list** | `artefacts/acer-debloat-final.txt`: every package the owner approved, split into batch sections. The target state. |
| **Applied list** | `artefacts/acer-debloat.txt`: what has actually been run through `disable.ps1` so far. Grows one batch at a time; the restore and check commands take this file. |
| **Batch** | Up to 10 packages appended to the applied list and applied in one `disable.ps1` run, then gated by the health check. Named B1, B2… |
| **Restore record** | The JSON `recovery.py` writes to `~/.cleanyourtv/recovery-<tv ip>-<hash of list path>.json` before the first change: each listed package's state before, the Home owner, the animation scales. `restore.ps1` replays it. Copied to `artefacts/records/`. |
| **Must-keep packages** | The owner's non-negotiables: Play Store/Services/GSF, streaming apps, Chromecast, Assistant, HDMI/AV/Live TV, OTA, Settings, setup wizard, keyboard, remote pairing and key handlers. Never listed. |
| **Health check** | `scripts/health-check.ps1`: the pass/fail gate after every batch. |
| **Home guard** | The upstream scripts' rule that the app owning Home is never disabled until another launcher answers HOME. |
| **Stock launcher** | `com.google.android.tvlauncher` on the Android TV variant. Stays enabled here (ADR 0001). |
| **New launcher** | CleanYourTV, package `com.gathin.tvhome`, built from `cleanyourtv/launcher`. |
| **HomeKeyService redirect** | The new launcher's accessibility helper (`HomeKeyService`) plus `stock_home_redirect`: when the stock home comes up, the TV is sent to the new launcher. This is how the Home button reaches CleanYourTV on this platform. |
| **Android TV variant / Google TV variant** | Acer R4 (device `R4`, `tvlauncher`) vs R4G (device `R4_GTV`, `launcherx`). The Google TV variant re-enables about 20 packages at every cold boot. |
| **Cold boot** | Power cable out for 30 s. Unlike standby/wake, it runs the firmware's boot jobs. |
| **Wireless debugging** | Android 11+ paired, encrypted ADB, with its own changing port. Used once to open port 5555 (`adb tcpip 5555`). |
