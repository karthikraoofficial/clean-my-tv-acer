# RUNBOOK: Acer AR43GR2851VQD (Acer R4G, Google TV 14)

How to undo, check, maintain or change the cleanup done on 2026-10-28. Everything runs from this
project folder on the Windows laptop, in PowerShell, with the TV on the same Wi-Fi.

```powershell
$P = 'C:\Users\Karthik Rao\Documents\VS Code\Clean My TV - Acer TV'; Set-Location $P
$py = "$P\cleanyourtv\tools\venv\Scripts\python.exe"; $tv = "$P\cleanyourtv\tools\tv.py"; $env:TV_HOST = '192.168.1.162'
```

If `cleanyourtv\` is missing (it isn't in git), re-create it: `git clone https://github.com/Gathin23/cleanyourtv`,
then `python -m venv cleanyourtv\tools\venv; cleanyourtv\tools\venv\Scripts\python.exe -m pip install -r cleanyourtv\tools\requirements.txt`,
then copy `artefacts\config.xml` to `cleanyourtv\launcher\app\src\main\res\values\config.xml`.

## What the TV looks like now

| What | State |
|---|---|
| Home screen | CleanYourTV (`com.gathin.tvhome`). Dock: YouTube, Netflix, Prime Video, JioHotstar, Crunchyroll, Spotify, Sony LIV. Browsehere first in the grid. |
| How Home reaches it | Google TV's launcher (`launcherx`) is still installed and still Android's Home. The **"Home button"** accessibility helper (HomeKeyService) sends every Home press, and every appearance of Google TV's home, to CleanYourTV. Google TV may show for about 0.3 s after Home and about 4 s at boot. Its home is started by a root firmware process, so it can't be removed fully without root. |
| Motion | No bounce on the focus highlight (`focus_overshoot=false`). Android animation speed is 0.5× (window, transition, animator). |
| Kept on purpose | Google TV launcher and setup wizard (the wizard owns your saved Wi-Fi), Play Store/Services, Assistant, Chromecast, HDMI/AV/Live TV, OTA updaters, Audio Link, TalkBack, YouTube Music, every installed app. |
| Debugging | Turned off at the end (see "Re-enable debugging"). |

## What was disabled, and why

9 packages, disabled with `pm disable-user --user 0` (nothing uninstalled). The list is `artefacts\acer-debloat.txt`.

| Package | What it is | Why off |
|---|---|---|
| `com.android.adservices.api` | Android ad services (Privacy Sandbox) | ads |
| `com.android.ondevicepersonalization.services` | on-device ad personalisation | ads |
| `com.android.federatedcompute.services` | federated compute for personalisation | telemetry |
| `com.android.tv.feedbackconsent` | collects bug reports and system logs for feedback | telemetry |
| `android.autoinstalls.config.scbc.device` | Play auto-installs of partner apps | bloat |
| `com.apps.mk.wd` | SCBC boot receiver with ClickAd/ClickApp/ClickVideo screens | ads |
| `com.apps.wifihotspot` | TV as a Wi-Fi hotspot | unused |
| `com.android.healthconnect.controller` | Health Connect | unused |
| `com.android.health.connect.backuprestore` | Health Connect backup | unused |

Already disabled before we started (left that way): `com.android.dreams.basic`, the "Colors" screensaver.

**Not disabled, because this firmware turns them back on at every cold boot:** SCBC gdpr agent, Google
feedback, Google partner setup (tested: it came back), Play Games, World Clock, TV Manager, demo stickers,
meeting service, SCast, FastCast, Google TV ambient mode. The ones with an icon (Play Games, World Clock,
TV Manager, FastCast) and the Live TV app are **hidden from the CleanYourTV grid** instead (`hidden_apps`).
Live TV is under the **Inputs** button.

## Restore everything (one line)

```powershell
powershell -ExecutionPolicy Bypass -File cleanyourtv\tools\restore.ps1 -TvHost 192.168.1.162 artefacts\acer-debloat.txt -Stock com.google.android.apps.tv.launcherx
```

This re-enables the 9 packages, puts Home and the animation speed (1.0) back as recorded before the first
change, and keeps disabled what was already disabled. The record is
`~\.cleanyourtv\recovery-192.168.1.162-4fac243a.json`, with a copy in `artefacts\records\`. If the record
is ever lost, copy it back there: it is keyed by the full path of `artefacts\acer-debloat.txt`, so
**don't move or rename that file**.

To also remove CleanYourTV: TV Settings → Apps → CleanYourTV → Uninstall. Google TV's home then answers
Home on its own, since it was never disabled.

Without a laptop: TV Settings → Apps → See all apps → Show system apps → pick a package → Enable.

## If Home starts opening Google TV again

The helper was switched off. That happens after a launcher reinstall or a force-stop: on this TV a force-stop
clears the setting.

- **On the TV:** Settings → Accessibility (or System → Accessibility) → **Home button** → On.
- **Over ADB:** `& $py -I $tv 'settings put secure enabled_accessibility_services com.gathin.tvhome/.HomeKeyService; settings put secure accessibility_enabled 1'`

Check it with `& $py -I $tv 'dumpsys accessibility | grep -A3 ''A11yInputFilter Info'''`. It should list
`KeyboardInterceptor`. If the helper shows as bound but Home still lands on Google TV, its process came up
half-started: `& $py -I $tv 'am force-stop com.gathin.tvhome'`, then enable it again as above.

## After a firmware update (or any time)

An OTA update can re-enable listed packages and new preloads can appear. Re-enable debugging (below), then:

```powershell
& $py -I cleanyourtv\tools\check.py artefacts\acer-debloat.txt com.google.android.apps.tv.launcherx         # report; exit 1 = drift
& $py -I cleanyourtv\tools\check.py --fix artefacts\acer-debloat.txt com.google.android.apps.tv.launcherx   # re-apply
& .\scripts\health-check.ps1 -Label after-ota                                                            # gate
```

Also confirm the helper is still on (previous section), and re-check that the build is still
`UKR1.260308` (`& $py -I $tv --probe`). If it changed, check which packages the firmware now re-enables
at cold boot before adding anything to the list.

## Change the dock, hidden apps or motion

1. Edit `cleanyourtv\launcher\app\src\main\res\values\config.xml`: `dock_apps`, `columns`, `hidden_apps`,
   `focus_overshoot`, `reduced_motion` (lightest motion) and so on. Copy it to `artefacts\config.xml` and commit.
2. Build and install, keeping Google TV's launcher:
   ```powershell
   $env:JAVA_HOME = [Environment]::GetEnvironmentVariable('JAVA_HOME','User'); $env:ANDROID_HOME = [Environment]::GetEnvironmentVariable('ANDROID_HOME','User')
   powershell -ExecutionPolicy Bypass -File cleanyourtv\launcher\build-and-install.ps1 -TvHost 192.168.1.162 -StockLauncher none -HomeKeyService
   ```
   On this TV the script stops at its "Home resolves to launcherx" check. That's expected. **Do not**
   follow its hint to disable setupwraith: that would delete your saved Wi-Fi network. Stop the script
   (Ctrl+C) if it doesn't exit.
3. `& $py -I $tv 'am force-stop com.gathin.tvhome'`, then turn the helper on (see above), press Home, and check.

Rearranging tiles needs no rebuild: hold OK on a tile → Move.

Animation speed (whole TV): `& $py -I $tv 'settings put global window_animation_scale 1.0; settings put global transition_animation_scale 1.0; settings put global animator_duration_scale 1.0'`
puts it back to normal; 0.5 is the current setting.

## Re-enable debugging (needed for every command above)

1. TV: Settings → System → About → press OK on **Android TV OS build** 7 times (only if Developer options is gone).
2. Settings → System → Developer options → **USB debugging** on, and the network/ADB debugging toggle if
   the menu has one. That opens port 5555, which `tv.py` uses.
3. `& $py -I $tv --probe`. Accept "Allow USB debugging?" on the TV if it asks.
4. When done, switch USB debugging (and Wireless debugging, if you used it) off again, then run
   `& $py -I cleanyourtv\tools\adb-closed.py 192.168.1.162`. Exit 0 means the port is closed.

## Notes about this TV

- Cold boot (power cut or unplug) takes about 48 s; about 29 s of that is firmware and Android core.
  Remote standby wakes in about 2 s with Energy mode "Optimized".
- A second user profile exists (user 10). JioCinema is installed only there. Nothing here touched it.
- The camera sensor-privacy toggle is on (the TV has no camera); the microphone is not blocked.
