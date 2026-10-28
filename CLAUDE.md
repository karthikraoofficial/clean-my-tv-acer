# Clean My TV: Acer AR43GR2851VQD

The TV is an **Acer R4G** (MOKA `R4_GTV`, **Google TV** 14, build `UKR1.260308/5597`); see upstream
`docs/devices/acer-r4g.md` and ADR 0004.

Debloat an Acer Android TV and put the CleanYourTV launcher on Home, using the cloned repo in
`cleanyourtv/` (upstream `github.com/Gathin23/cleanyourtv`). The plan is `PLAN.md`; the runbook,
once written, is `RUNBOOK.md`.

## Hard rules

- Only `pm disable-user --user 0`. Never `pm uninstall`, never `pm clear`, no root, nothing flashed.
- Back up first. The restore record in `~\.cleanyourtv\` must exist before the first package is
  disabled; copy it to `artefacts\records\` after every batch.
- Never leave the TV without a working Home. No `FORCE_HOME`, no `FORCE_SETUPWRAITH`. Never disable
  `com.google.android.apps.tv.launcherx` or `com.google.android.tungsten.setupwraith`: the firmware
  re-enables setupwraith at every cold boot and Home goes black, and setupwraith owns a saved Wi-Fi network (ADR 0001).
- Only list packages that stay disabled across a cold boot (ADR 0004); hide the rest from the launcher grid.
- Ask before disabling any package that is not certain. Ambiguous means keep.
- Batches of 10 or fewer, appended to the applied list `artefacts\acer-debloat.txt` (ADR 0003).
  After each batch: screenshot, `scripts\health-check.ps1`, and a check from the owner.
- If anything breaks: stop, re-enable that batch, report.
- Every artefact (lists, records, logs, screenshots) lives under `artefacts\`.
- Never start a factory or test package (`com.apps.factory.ui`, `com.realtek.factorytools`), not
  even to look. Use `dumpsys package <name>`.
- Use the PowerShell versions of the repo scripts, not `*.sh`: `bash` on this PATH is WSL (ADR 0002).
- Do not edit anything in `cleanyourtv/` except
  `launcher/app/src/main/res/values/config.xml`.
- Never commit or publish device identifiers. `artefacts/` is git-ignored.

## Must stay working

Play Store, Play Services, GSF and Google sign-in; every installed streaming app; Chromecast
(`com.google.android.apps.mediashell`); voice on the mic button (`com.google.android.katniss`);
HDMI, AV and Live TV (`com.realtek.tv.passthrough`, `com.realtek.tv`, `com.realtek.dtv`, `com.realtek.tv.atv`,
`com.mk.service.tvmidware`); OTA (`com.apps.ota`, `com.apps.authota`, `com.realsil.ota`,
`com.google.android.tv.dfuservice`); Settings, setup wizard, keyboard, Bluetooth remote pairing. `scripts\health-check.ps1` holds the full list.

## Secrets and identifiers

- TV address: `192.168.1.162` (LAN only). No passwords or keys in this repo.
- The ADB key `tv.py` uses lives in `cleanyourtv\tools\adbkey\` (ignored by upstream's `.gitignore`).

## Commands (PowerShell, from the project root)

Debugging on the TV was switched **off** on 2026-10-28 (port 5555 closed). Re-enable it first: RUNBOOK.md,
"Re-enable debugging". After any launcher reinstall, force-stop `com.gathin.tvhome` and re-enable
HomeKeyService (RUNBOOK.md, "If Home starts opening Google TV again").

```powershell
$P = (Get-Location).Path; $R = "$P\cleanyourtv"; $A = "$P\artefacts"
$py = "$R\tools\venv\Scripts\python.exe"; $tv = "$R\tools\tv.py"; $env:TV_HOST = '192.168.1.162'
& $py -I $tv --probe                                    # model, Android version, firmware
& $py -I $tv 'pm list packages -d --user 0'             # what is disabled
& $py -I $tv --screenshot "$A\shots\x.png" HOME         # press HOME, capture
powershell -ExecutionPolicy Bypass -File "$R\tools\disable.ps1" -TvHost 192.168.1.162 "$A\acer-debloat.txt"
powershell -ExecutionPolicy Bypass -File "$R\tools\restore.ps1" -TvHost 192.168.1.162 "$A\acer-debloat.txt" -Stock com.google.android.apps.tv.launcherx
& "$P\scripts\health-check.ps1"                         # gate after every batch
& $py -I "$R\tools\check.py" "$A\acer-debloat.txt"      # after a firmware update; --fix to re-apply
& $py -I "$R\tools\adb-closed.py" 192.168.1.162         # exit 0 = ADB port closed
```

Build prerequisites (user scope): `JAVA_HOME` = Temurin 17 under `%LOCALAPPDATA%\Programs\Temurin`,
`ANDROID_HOME` = `%LOCALAPPDATA%\Android\Sdk` (platform 34, build-tools 34.0.0, platform-tools).

## Agent skills

### Issue tracker

Local markdown under `.scratch/acer-tv-cleanup/` (spec = PRD, `issues/NN-*.md` = tickets), with a kanban in `BOARD.md`. See `docs/agents/issue-tracker.md`.

### Triage labels

The five default labels (`needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: `CONTEXT.md` and `docs/adr/` at the root. See `docs/agents/domain.md`.
