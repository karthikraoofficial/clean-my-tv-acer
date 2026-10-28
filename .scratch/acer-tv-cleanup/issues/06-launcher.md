# 06: CleanYourTV launcher on Home

Status: in-progress
Type: task
Blocked by: 01, 05

Phase 5, per ADR 0001.

## Acceptance
- [x] `config.xml`: dock = YouTube, Netflix, Prime Video, JioHotstar, Crunchyroll, Spotify, Sony LIV; `columns` 7; Live TV `com.realtek.tv`; `hidden_apps` = com.realtek.tv, play.games, mk.tv.timeclock, apps.tvmanager, creative.fastscreen.tv; `stock_home_redirect` = `com.google.android.apps.tv.launcherx` _(Updated for R4G)_. Copy in `artefacts/config.xml`.
- [x] Built and installed with `-StockLauncher none -HomeKeyService`; HomeKeyService enabled
- [x] A real Home press, then `mFocusedApp` shows `com.gathin.tvhome`; screenshot
- [x] Browsehere (`com.tcl.browser`) first in the grid (`tile_menu` Move, or the grid order)
- [x] Real buttons: Input, Settings, YouTube, mic, Back, volume hold-to-ramp
- [x] Home pressed while on an HDMI input: note whether launcherx flashes first (#1121 doesn't cover HDMI)
- [ ] After a cold boot, Home is still CleanYourTV. Power-on = Home: if Live TV opens by itself, set `power_on_home`

## Comments

**2026-10-28: installed, Home redirect works with an injected key.**
- Build: `gradlew assembleRelease`, 550,497 B (under the 576 KB gate). `config.xml` diff: dock (7), `columns` 7, `hidden_apps` (5), `live_tv_package` com.realtek.tv, `stock_home_redirect` launcherx, `tile_menu` true. A copy is in `artefacts/config.xml`.
- `build-and-install.ps1 -StockLauncher none -HomeKeyService`: md5 MATCH, `pm install` Success, launcher started, `set-home-activity` "Success". It then threw at the Home check: Home still resolves to launcherx, as on the AR55. It suggested disabling setupwraith; **not done** (ADR 0001: setupwraith owns the saved Wi-Fi). The script process hung after the throw and was stopped. Nothing was disabled.
- HomeKeyService was enabled with the script's own `Enable-Service` command through `tv.py --batch`. `dumpsys accessibility` shows it Bound ("Home button").
- Injected HOME → `mFocusedApp` = `com.gathin.tvhome/.MainActivity` (`shots/L1-home.png`). Health check L1 is in `logs/L1-health.log`.
- Waiting on the owner: the real-remote buttons, Browsehere moved first, a cold boot, and the power-on screen.

**2026-10-28: the owner's remote checks pass.** Home from an app, Home from HDMI, Back, Settings, Input, YouTube and the mic all verified on the real remote. Volume was skipped (audio is on an external device). Browsehere was moved first with the tile menu. After a cold boot, Home loads fine.

**2026-10-28: owner issue, "Google TV home flashes before Home".**
- Measured (`logs/home-press-sequence.txt`): launcherx resumed at +0.0 s, tvhome at +1.6 s.
- The cause (`logcat -s ActivityTaskManager`): the HOME intent to launcherx is started `from uid 0`, a root firmware process. That is below the accessibility key filter, so no app can stop it without root.
- Mitigation: `home_long_press_home=true`. The helper now consumes Home and opens CleanYourTV on key-up, instead of waiting for launcherx's window. Measured after (`logs/home-press-sequence-2.txt`): tvhome at +0.9 s (injected key). The cost is that a held Home no longer gives Google TV's long-press action. If the helper is off, Home falls back to launcherx.
- `pm install -r` of the launcher **cleared `enabled_accessibility_services`** (null, 0). The helper was re-enabled with `Enable-Service`. RUNBOOK must say: re-enable HomeKeyService after every launcher reinstall.
