# PLAN: Clean My TV (Acer AR43GR2851VQD)

> Approved 2026-10-28. During planning the only contact with the TV was a ping and a TCP connect to port 5555 (no ADB handshake): it answered the ping and **refused 5555**.

## Updates since approval (2026-10-28)

- **Owner's answers recorded** in the PRD (`.scratch/acer-tv-cleanup/spec.md`), "Decisions from the owner". In short:
  - Dock: 7 slots (YouTube, Netflix, Prime Video, JioHotstar, Crunchyroll, Spotify, Sony LIV), with Browsehere first in the grid.
  - Keep: Assistant, OTA, Audio Link, YouTube Music, TalkBack.
  - Disable: FastCast, SCast, Play Movies, Colors screensaver.
  - The TV is on Wi-Fi. Google TV variant → stop and re-plan. Power-on = Home. No extras.
  - Tracker: local markdown plus `git init`, mirrored to a private GitHub repo.
- _(Updated)_ **Tracker paths:** the PRD is `.scratch/acer-tv-cleanup/spec.md` and the tickets are `.scratch/acer-tv-cleanup/issues/01..08` (the setup skill's local-markdown convention), not `docs/PRD.md` / `docs/tickets/`.
- _(Updated)_ **Prerequisites** were installed per-user from the official zips (Temurin 17 to `%LOCALAPPDATA%\Programs\Temurin`; Android cmdline-tools then `sdkmanager` to `%LOCALAPPDATA%\Android\Sdk`) instead of winget, so no admin prompt was needed. `JAVA_HOME` and `ANDROID_HOME` are set for the user.
- _(Added)_ **Draft approved list:** `artefacts/acer-debloat-final.txt` (24 packages in B1–B4), pending discovery and the owner's sign-off (ticket 04).
- _(Updated)_ **Questions 1–13** are all answered; the "Questions before execution" section below is kept for the record.

## Context

You want to remove ads, sponsored rows and telemetry from your Acer Android TV, and put the CleanYourTV launcher on Home, without breaking Play Store, your streaming apps, Cast, voice, HDMI and Live TV, OTA, or Settings. The source of truth is `github.com/Gathin23/cleanyourtv` (read on 2026-10-28, `main`, last pushed today): `PROMPT.md`, `AGENTS.md` (which `CLAUDE.md` imports), `README.md`, `docs/TROUBLESHOOTING.md`, `docs/restore.md`, `docs/devices/acer-r4g.md`, and the tool sources.

**Acer folders in `examples/`:** only one, `examples/acer-ar55ar2851udpro/`, with `README.md`, `debloat.txt`, `config.json` and `tv.json`. There is also a note (not a list) for the Google TV variant: `docs/devices/acer-r4g.md`.

### Findings that change your plan

1. **Your model may be the Google TV variant.** The tested set is `AR55**AR**2851UDPRO` (device `R4`, Android TV, stock launcher `com.google.android.tvlauncher`). Yours is `AR43**GR**2851VQD`. The repo's Google TV Acer (`R4G`, device `R4_GTV`, launcher `launcherx`) is on the same build `UKR1.260308`, but its modified `com.android.tv.settings` **re-enables about 20 packages at every cold boot**, including setupwraith, and that left Home black for one owner. Phase 1 decides which variant you have. If it's `R4_GTV` or launcherx, I stop and re-plan with you.
2. **The stock launcher must stay enabled on this platform.** On the AR55, `set-home-activity` doesn't stick ("Result set changed, dropping preferred activity"). The tested method keeps `tvlauncher` on and gives the Home button to the new launcher through `HomeKeyService` plus `stock_home_redirect`. **Your Phase 5 step "re-run the list so the stock launcher is disabled" is dropped**, because it conflicts with your Home-guard rule. `com.google.android.tvrecommendations` is disabled instead, which removes the sponsored rows from the stock home too.
3. **Port 5555 is closed.** The AR55 was reached by pairing through Wireless debugging with Google's `adb`, then running `adb tcpip 5555`. That makes **platform-tools (adb.exe) a prerequisite.**
4. **Use the PowerShell twins on Windows**: `tools\disable.ps1`, `restore.ps1`, `theme.ps1` and `launcher\build-and-install.ps1`, run with Windows' `python.exe` venv. The `bash` on your PATH is WSL's (`C:\WINDOWS\system32\bash.exe`), so `tools/disable.sh` would run inside Ubuntu, which has a different network and no `tools\venv\Scripts`. The twins have the same guards: core-package refusal, the Home guard, the setupwraith Wi-Fi guard, the TV-input guard, and the restore record via `recovery.py --save`.
5. **`disable.ps1` applies a whole list in one go, and the restore record is keyed by the list's absolute path.** So batching uses **one applied list that grows by at most 10 lines per run**: `artefacts\acer-debloat.txt`. Each run adds only the new names to the same record in `~\.cleanyourtv\`, so one `restore.ps1` undoes everything.
6. **YouTube is in the example list**, and its remote button is hard-wired to it (`com.realtek.keyinterceptserver`, keycode 2030). You use YouTube, so it stays enabled.

## Prerequisites (checked read-only on this laptop)

| Need | Status |
|---|---|
| Python 3 | ✅ 3.13.7 |
| git | ✅ 2.51.0 |
| winget, gh | ✅ (gh logged in as karthikraoofficial) |
| **JDK 17** | ❌ missing (no `java`, no `JAVA_HOME`, no Android Studio JBR) |
| **Android SDK platform 34** | ❌ missing (no `ANDROID_HOME`, no `%LOCALAPPDATA%\Android\Sdk`) |
| **build-tools 34.0.0** | ❌ missing |
| **platform-tools (adb)** | ❌ missing, needed for Wireless debugging pairing |

Install commands (lightweight, exactly JDK 17, no Android Studio):

```powershell
winget install -e --id EclipseAdoptium.Temurin.17.JDK
# Android command-line tools: download "commandlinetools-win-*_latest.zip" from
# https://developer.android.com/studio#command-tools and unzip so this path exists:
#   %LOCALAPPDATA%\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat
$sdk = "$env:LOCALAPPDATA\Android\Sdk"
& "$sdk\cmdline-tools\latest\bin\sdkmanager.bat" --licenses
& "$sdk\cmdline-tools\latest\bin\sdkmanager.bat" "platforms;android-34" "build-tools;34.0.0" "platform-tools"
$jdk = (Get-ChildItem 'C:\Program Files\Eclipse Adoptium' -Directory | Where-Object Name -like 'jdk-17*' | Select-Object -First 1).FullName
setx JAVA_HOME $jdk
setx ANDROID_HOME $sdk
# new terminal, then:  java -version  ;  & "$env:ANDROID_HOME\platform-tools\adb.exe" version
```

Alternative: `winget install -e --id Google.AndroidStudio`, then use SDK Manager to install Android 14 (API 34), Build-Tools 34.0.0 and Platform-Tools. `build-and-install.ps1` finds Studio's bundled JBR automatically, but that JBR is JDK 21 rather than 17.

---

## Phase 0: Workspace (project management first)

**Project management, per your global CLAUDE.md** (Matt Pocock framework; the tracker isn't configured yet, see Q11):
- `.scratch/acer-tv-cleanup/spec.md` _(Updated: was docs/PRD.md)_: problem, solution, user stories (the non-negotiables become acceptance criteria).
- `.scratch/acer-tv-cleanup/issues/01..08` _(Updated: was docs/tickets/)_: one per phase, each with `Blocked by:`. The chain: 01 prereqs → 02 connect/probe → {03 backup, 04 final list} → 05 debloat (B1..B4) → 06 launcher → 07 verify → 08 harden/runbook.
- `BOARD.md`: a kanban with Backlog / Ready / In progress / Done columns.
- **TDD analogue:** before any disabling, write `scripts\health-check.ps1`. It asserts every NON-NEGOTIABLE package is enabled, Home resolves and is focused, and Play Store plus one streaming app resume. Run it against the untouched TV, where it must pass. To prove it can fail, run it once with a deliberately bogus expected package. It then gates every batch.
- Docs kept in sync: `CONTEXT.md` (terms such as *applied list*, *restore record*, *Home guard*, *HomeKeyService redirect*, *batch*, *health check*), `docs/adr/` (0001 the stock launcher stays enabled; 0002 PowerShell twins instead of WSL bash; 0003 one growing applied list for a cumulative record), a project `CLAUDE.md` (hard rules, `TV_HOST`, commands) and `README.md`.

```powershell
$P  = "C:\Users\Karthik Rao\Documents\VS Code\Clean My TV - Acer TV"
Set-Location $P
git clone https://github.com/Gathin23/cleanyourtv
$R  = "$P\cleanyourtv";  $A = "$P\artefacts"
New-Item -ItemType Directory -Force "$A\backup","$A\lists","$A\shots","$A\records","$A\logs","$P\scripts","$P\docs\adr","$P\docs\tickets" | Out-Null
python -m venv "$R\tools\venv"
& "$R\tools\venv\Scripts\python.exe" -m pip install -r "$R\tools\requirements.txt"
$py = "$R\tools\venv\Scripts\python.exe";  $tv = "$R\tools\tv.py"
$env:TV_HOST = "192.168.1.162"
& $py -I $tv --help
```

- **Success:** the clone is present, `tv.py --help` prints its usage, and the folders exist.
- **Rollback:** delete `cleanyourtv\` and `tools\venv`. Nothing on the TV changed.

## Phase 1: Connect and probe

1. Try `& $py -I $tv --probe`. If 5555 still refuses (expected), pair over Wireless debugging. On the TV: Developer options → Wireless debugging → on → Pair device with pairing code. You read me the pairing port, code and connect port.
   ```powershell
   $adb = "$env:ANDROID_HOME\platform-tools\adb.exe"
   & $adb pair 192.168.1.162:<pairPort> <code>
   & $adb connect 192.168.1.162:<connectPort>
   & $adb mdns services            # note the _adb-tls-connect port for Phase 7
   & $adb tcpip 5555
   & $py -I $tv --probe            # "Allow USB debugging?" appears on the TV for tv.py's key: tick Always allow
   ```
2. **Identity gate:**
   ```powershell
   & $py -I $tv 'getprop ro.product.model; getprop ro.product.device; getprop ro.build.fingerprint; getprop ro.build.version.sdk; getprop ro.build.display.id'
   & $py -I $tv 'pm list packages | grep -E "tvlauncher|launcherx|setupwraith"'
   ```
   It matches the AR55 recipe if the device is `R4`, the SDK is 34, and `tvlauncher` is present without `launcherx`. I'll report every difference: the model will differ (43" vs 55"), and the build or incremental may too. **If the device is `R4_GTV` or `launcherx` is present: STOP and re-plan** (see Finding 1).
3. **Discovery** (read-only, output to `artefacts\lists\`):
   ```powershell
   & $py -I $tv 'pm list packages -f --user 0'   > "$A\lists\packages-all.txt"
   & $py -I $tv 'pm list packages -3'            > "$A\lists\packages-3rdparty.txt"
   & $py -I $tv 'cmd package query-activities --brief -a android.intent.action.MAIN -c android.intent.category.HOME' > "$A\lists\home-claimants.txt"
   & $py -I $tv 'cmd package resolve-activity --brief -a android.intent.action.MAIN -c android.intent.category.HOME' > "$A\lists\home-owner.txt"
   & $py -I $tv "dumpsys wifi | grep -o 'cname=[^ ]*'" > "$A\lists\wifi-owner.txt"
   & $py -I "$R\tools\privacy.py" > "$A\lists\privacy-report.txt"
   & $py -I "$R\tools\privacy.py" --write "$A\lists\privacy-candidates.txt"
   & $py -I $tv 'dumpsys package <unknown.pkg>'   # per unfamiliar name; never start factory/test packages
   ```
   I also diff the package list against the AR55 list, its "kept on purpose" and "not touched" sets, and the R4G preloads (`com.jio.media.stb.ondemand`, `com.yupptv.scope.tvapp`, `com.mxtech.videoplayer.television`, `com.alphainventor.filemanager`).
- **Success:** ADB connected, the variant is known, and the discovery files are saved.
- **Rollback:** nothing to undo yet. Phase 7 closes port 5555.

## Phase 2: Backup

```powershell
& $py -I $tv 'pm list packages -d --user 0' > "$A\backup\disabled-before.txt"
& $py -I $tv 'pm list packages -e --user 0' > "$A\backup\enabled-before.txt"
& $py -I $tv 'getprop'                      > "$A\backup\getprop.txt"
foreach ($ns in 'global','secure','system') { & $py -I $tv "settings list $ns" > "$A\backup\settings-$ns.txt" }
& $py -I $tv 'wm size; wm density; settings get secure display_density_forced' > "$A\backup\display.txt"
& $py -I $tv --screenshot "$A\shots\00-before-home.png" HOME
& $py -I "$R\tools\recovery.py" --save "$A\acer-debloat.txt"     # batch 1 contents only, once Phase 3 is approved
Copy-Item "$env:USERPROFILE\.cleanyourtv\recovery-192.168.1.162-*.json" "$A\records\"
```

- **Success:** all the files are non-empty, the screenshot shows the stock Home, and a `recovery-192.168.1.162-<hash>.json` exists and is copied into `artefacts\records\`. Then `scripts\health-check.ps1` passes as the baseline.
- **Rollback:** read-only phase, nothing to undo.
- I'll also ask what's plugged into the TV's USB ports. Some sets cut USB power while debugging is on.

## Phase 3: Final list

- `artefacts\acer-debloat-final.txt` is the approved master: the AR55 list, plus discovery finds, minus everything under NON-NEGOTIABLES, plus your answers. It's split into commented batch sections of 10 or fewer.
- `artefacts\acer-debloat.txt` is the **applied** list. It starts with batch 1 only and grows by one batch per run.
- The header records the source, the model, the build and the "kept on purpose" list.
- **Gate:** you approve `acer-debloat-final.txt` before Phase 4.

Proposed batches, assuming the review table below is accepted:

| Batch | Packages |
|---|---|
| B1 telemetry and ad services (6) | gdpr, google feedback, feedbackconsent, adservices.api, ondevicepersonalization, federatedcompute |
| B2 ads, rows and demo (7) | apps.mk.wd, autoinstalls.config.scbc.device, tvrecommendations, eshow, esticker, meeting.service, tvmanager |
| B3 not needed (≤9) | healthconnect controller and backuprestore, wifihotspot, timeclock, play.games, videos, networkspeed, dreams.basic, partnersetup (last, with a Play Store check) |
| B4 your answers and discovery extras (≤10) | e.g. youtube.tvmusic, fastscreen, scast, talkback, audiolink, R4G-style preloads you don't use |

## Phase 4: Debloat in batches

For each batch Bn, in order:

```powershell
# 1. append batch n's lines from acer-debloat-final.txt to acer-debloat.txt
powershell -ExecutionPolicy Bypass -File "$R\tools\disable.ps1" -TvHost 192.168.1.162 "$A\acer-debloat.txt" *>&1 | Tee-Object "$A\logs\B<n>-disable.log"
Copy-Item "$env:USERPROFILE\.cleanyourtv\recovery-192.168.1.162-*.json" "$A\records\" -Force
& $py -I $tv --screenshot "$A\shots\B<n>-home.png" HOME
& "$P\scripts\health-check.ps1" | Tee-Object "$A\logs\B<n>-health.log"
```

The health check covers: the disabled set equals what's expected; all NON-NEGOTIABLES are still enabled; `mFocusedApp` is the Home owner; the Play Store opens (screenshot); one streaming app reaches `ResumedActivity`, rotating through YouTube, Netflix, Prime Video and JioHotstar (Netflix screenshots come out blank, which is normal).

- **Success:** the script reports every package disabled, the health check passes, the screenshot looks right, and you confirm the remote feels normal.
- **Rollback (one batch):** stop. Then for each package in that batch, one call each: `& $py -I $tv 'pm enable --user 0 <pkg>'`. Remove those lines from `acer-debloat.txt`, re-run the health check, and tell you.
- **After the last batch:** `& $py -I $tv sync`, wait 15 s, `& $py -I $tv --reboot`, then a cold boot (power cable out for 30 s). Compare `pm list packages -d` with the list, and check `logcat -d | grep RecoveryActivity` is empty.
- **Full rollback:** `powershell -ExecutionPolicy Bypass -File "$R\tools\restore.ps1" -TvHost 192.168.1.162 "$A\acer-debloat.txt"` (the `-Stock` default `com.google.android.tvlauncher` is correct for Android TV).

## Phase 5: Launcher (AR55 method)

1. Check the SDK is at least 26 (it's 34) and that the TV accepts installs.
2. Edit `cleanyourtv\launcher\app\src\main\res\values\config.xml`, and keep a copy in `artefacts\config.xml`:
   - `dock_apps` = your order (default: `com.google.android.youtube.tv`, `com.netflix.ninja`, `com.amazon.amazonvideo.livingroom`, `in.startv.hotstar`, then more if the dock is bigger)
   - `columns` = dock size (4–7)
   - `hidden_apps` = `com.apps.livetv`; `live_tv_package` = `com.apps.livetv`
   - `stock_home_redirect` = `com.google.android.tvlauncher`
   - optional: `tile_menu`, `icon_only_buttons`, `wifi_label_width` 300 (from the AR55 `config.json`)
3. Build and install, keeping the stock launcher:
   ```powershell
   powershell -ExecutionPolicy Bypass -File "$R\launcher\build-and-install.ps1" -TvHost 192.168.1.162 -StockLauncher none -HomeKeyService *>&1 | Tee-Object "$A\logs\launcher-install.log"
   ```
   On the AR55 the script installs and starts the launcher, then stops at its "Home resolves to tvlauncher" check before turning `HomeKeyService` on. That's expected, and nothing is disabled. You then turn it on via TV Settings → Accessibility → Home button (or I run the script's own `enabled_accessibility_services` lines).
4. **Confirm:** you press the real Home button, then `& $py -I $tv 'dumpsys activity activities | grep mFocusedApp'` shows `com.gathin.tvhome`. Screenshot `L1-home.png`. Holding volume must still ramp.
5. Remote buttons: you press Input, Settings, YouTube, mic, Back and volume. Only if Input or Settings stop working do I add `-InputKeyService` / `settings_key_keycodes` and reinstall. The AR55 needed neither.
6. After the first cold boot: `logcat -b events -d | grep wm_set_resumed_activity`. If Live TV opens by itself, you choose `power_on_home` (Home) or `boot_to_live_tv` (Live TV), never both.

- **Success:** Home opens CleanYourTV after the cold boot, and the dock is in your order.
- **Rollback:** `& $py -I $tv 'pm disable-user --user 0 com.gathin.tvhome'` gives Home straight back to tvlauncher, which never left. Full removal through TV Settings → Apps is your call, since it's an uninstall of an app we added, not a system one.

## Phase 6: Verify (every item ticked in `BOARD.md`, with screenshots in `artefacts\shots\V*`)

- [ ] Install a new free app from Play Store; it appears in the launcher grid
- [ ] Update an app from Play Store
- [ ] Play Netflix, Prime Video, JioHotstar and YouTube
- [ ] Cast to the TV from your phone
- [ ] Voice search on the remote's mic
- [ ] Each HDMI input, plus Live TV, via the Inputs pill
- [ ] Remote: Input, Home, Back, Settings, volume (hold to ramp)
- [ ] Reboot, then a cold boot: Home is still CleanYourTV, no sponsored rows, `pm list packages -d` unchanged

## Phase 7: Harden and document

1. Before switching anything off, note the Wireless debugging port (`adb mdns services`). Then on the TV turn off Wireless debugging, Network/ADB debugging and USB debugging, revoke the USB debugging authorisations, and remove the laptop from Paired devices.
2. `& $py -I "$R\tools\adb-closed.py" 192.168.1.162 <wirelessPort>` must exit 0 (run this before the reboot).
3. Reboot, then `& $py -I "$R\tools\adb-closed.py" 192.168.1.162` must exit 0 (port 5555 refused). Only the tool's "closed" counts.
4. Write `RUNBOOK.md`:
   - what was disabled and why (a table from the final list)
   - restore in one line: `powershell -ExecutionPolicy Bypass -File cleanyourtv\tools\restore.ps1 -TvHost 192.168.1.162 artefacts\acer-debloat.txt` (no launcherx argument, since this is Android TV)
   - after a firmware update: re-enable debugging, then `& $py -I cleanyourtv\tools\check.py artefacts\acer-debloat.txt`, and `--fix` if it drifted
   - how to re-enable debugging: Build ×7, then Wireless debugging pairing and `adb tcpip 5555`
   - how to change the dock (`config.xml`, then rebuild, or push a theme with `tools\theme.ps1`)
5. Close the tickets with the evidence (log and screenshot paths), close the PRD, and bring CONTEXT, ADRs, CLAUDE.md and README up to date.

**Optional (only if you say yes):** AdGuard Private DNS (`private_dns_specifier dns.adguard-dns.com`, then `private_dns_mode hostname`; undo with `opportunistic`; it doesn't block YouTube ads, and it bypasses router Pi-hole rules), a theme from `themes/`, the clock screensaver.

---

## Acer `debloat.txt` review (the 28 entries in `examples/acer-ar55ar2851udpro/debloat.txt`)

| # | Package | What it is | Type | Recommendation | Touches a NON-NEGOTIABLE? |
|---|---|---|---|---|---|
| 1 | com.apps.function.gdpr | SCBC data-consent agent | Telemetry | Disable | – |
| 2 | com.google.android.feedback | Google feedback reporter | Telemetry | Disable | – |
| 3 | com.android.tv.feedbackconsent | Feedback consent UI | Telemetry | Disable | – |
| 4 | com.android.adservices.api | Android Privacy Sandbox ad services | Ad | Disable | – |
| 5 | com.android.ondevicepersonalization.services | On-device ad personalisation | Ad | Disable | – |
| 6 | com.android.federatedcompute.services | Federated learning for ads/personalisation | Telemetry | Disable | – |
| 7 | com.apps.mk.wd | Boot receiver with ClickAd/ClickApp/ClickChannel | Ad | Disable | – |
| 8 | android.autoinstalls.config.scbc.device | Play auto-installs of partner apps | Ad/bloat | Disable | ⚠ Play-adjacent: stops pushed installs only; Play Store checked right after |
| 9 | com.google.android.tvrecommendations | Sponsored and recommendation rows on stock Home | Ad | Disable | – |
| 10 | com.apps.eshow | In-store demo/promo | Bloat | Disable | – |
| 11 | com.apps.esticker | Demo sticker overlay | Bloat | Disable | – |
| 12 | com.mk.tv.meeting.service | Digital-signage service with an accessibility service | Bloat | Disable | – |
| 13 | com.apps.tvmanager | "TV manager" cleaner | Bloat | Disable | – |
| 14 | com.android.healthconnect.controller | Health Connect | Bloat | Disable | – |
| 15 | com.android.health.connect.backuprestore | Health Connect backup | Bloat | Disable | – |
| 16 | com.apps.wifihotspot | TV as a Wi-Fi hotspot | Bloat | Disable (unless you share Wi-Fi from the TV) | – |
| 17 | com.mk.tv.timeclock | World clock | Bloat | Disable | – |
| 18 | com.apps.function.audiolink | "Audio Link" (SCBC audio feature, purpose unclear) | Unsure | **Ask me** | ⚠ possibly audio output, see Q5 |
| 19 | com.google.android.play.games | Play Games | Bloat | Disable | – |
| 20 | com.google.android.partnersetup | Google partner setup / RLZ pings | Telemetry | Disable, alone at the end of B3, with a Play Store check | ⚠ Google-side; not vending/gms/gsf; tested OK on the AR55 |
| 21 | com.android.dreams.basic | "Colors" screensaver (Backdrop kept) | Bloat | Disable | – |
| 22 | com.google.android.marvin.talkback | TalkBack screen reader | Unsure (accessibility) | **Ask me** | ⚠ Settings/accessibility |
| 23 | com.google.android.youtube.tv | YouTube | **Your app** | **KEEP** | ⚠ yes: your app, and the remote's YouTube key needs it |
| 24 | com.google.android.youtube.tvmusic | YouTube Music | Preload | **Ask me** | Streaming app |
| 25 | com.creative.fastscreen.tv | FastCast Miracast receiver (screen mirroring) | Casting | **Ask me** | ⚠ casting-adjacent; Chromecast (mediashell) is separate and stays |
| 26 | com.apps.scast | SCast casting receiver | Casting | **Ask me** | ⚠ same as above |
| 27 | com.google.android.videos | Google Play Movies & TV | Preload | Disable (unless you buy/rent there) | – |
| 28 | com.mk.tv.networkspeed | Network speed test (Firebase) | Bloat | Disable | – |

**Never disabled (kept by me and by the example):** `com.android.vending`, `com.google.android.gms`, `com.google.android.gsf`, `com.google.android.katniss` (mic), `com.google.android.apps.mediashell` (Cast), `com.google.android.tvlauncher` (stock Home, still needed), `com.google.android.tungsten.setupwraith` (owns the saved Wi-Fi on the AR55), `com.realtek.leanbacklauncher.partnercustomizer` (Inputs button), `com.apps.passthrough` (HDMI/AV), `com.apps.livetv`, `com.apps.atv`, `com.apps.dtv`, `com.mk.service.tvmidware`, `com.apps.sys`, `com.apps.smartmenu`, the key handlers (`com.apps.smartkey`, `com.apps.virtualkey`, `com.mk.tv.fivekey`, `com.realtek.keyinterceptserver`, `com.realtek.android.globalkeyhandler`, `com.apps.bluetoothremote`), `com.apps.ota` and `com.apps.authota` (OTA), Settings, `com.android.tv.settings`, the keyboard, Netflix, Prime Video, JioHotstar and all your other installed streaming apps. Not touched (unclear or factory): `com.apps.factory.ui`, `com.realtek.factorytools`, `com.apps.biz.ds`, `com.apps.biz.mt`, `com.seraphic.hbbtv.app`, `com.apps.usbmediaplayer`.

## Questions before execution

1. **Dock:** how many slots (4, 5, 6 or 7), and the exact apps and order after YouTube, Netflix, Prime Video and JioHotstar? (The "etc" matters: which ones?)
2. **Voice assistant:** keep Google Assistant on the mic button? (Plan: yes, as a non-negotiable.)
3. **Casting:** Chromecast stays. Do you ever use screen *mirroring* (Miracast) through FastCast or SCast? If not, disable both.
4. **Firmware updates:** keep `com.apps.ota` and `com.apps.authota` enabled? (Plan: yes.)
5. **Audio Link** (`com.apps.function.audiolink`): do you use any "send TV audio to phone / Audio Link" feature? If you're unsure, I keep it.
6. **TalkBack**: does anyone in the house use the screen reader? **YouTube Music**: use it?
7. **Which other streaming apps are installed** that I must protect (SonyLIV, Zee5, SunNXT, JioCinema…)? Discovery lists them, and I'll treat them all as keep unless you say otherwise.
8. **Play Movies** and the **Colors screensaver**: OK to disable?
9. **USB ports:** what's plugged into the TV's USB? Is the TV on Wi-Fi or a USB Ethernet adapter?
10. **If Phase 1 shows the Google TV variant (`R4_GTV`/launcherx):** should I stop for a re-plan (recommended), or go debloat-only with the stock launcher kept and the HomeKeyService redirect?
11. **Tracker for the PRD, tickets and board:** a local markdown tracker in this folder plus `git init` (recommended; the artefacts hold device identifiers, so nothing gets pushed), or a **private** GitHub repo with issues and a Projects board? Either way I'll run `/setup-matt-pocock-skills` first.
12. **Power-on screen** after the launcher goes in: Home or Live TV, if the firmware opens Live TV by itself?
13. **Optional extras:** AdGuard Private DNS (does your router already run Pi-hole or AdGuard Home?), a theme from `themes/`, the clock screensaver?

## Verification of this plan itself

- Every command above uses only tools in the cloned repo, the venv Python, and the platform-tools `adb` for pairing.
- No `pm uninstall`, no `pm clear`, no root, no `FORCE_HOME`/`FORCE_SETUPWRAITH`. The stock launcher is never disabled.
- The restore record exists in `~\.cleanyourtv\` and is copied to `artefacts\records\` before batch 1 and after each batch.
