# 06: CleanYourTV launcher on Home

Status: in-progress
Type: task
Blocked by: 01, 05

Phase 5, per ADR 0001.

## Acceptance
- [x] `config.xml`: dock = YouTube, Netflix, Prime Video, JioHotstar, Crunchyroll, Spotify, Sony LIV; `columns` 7; Live TV `com.realtek.tv`; `hidden_apps` = com.realtek.tv, play.games, mk.tv.timeclock, apps.tvmanager, creative.fastscreen.tv; `stock_home_redirect` = `com.google.android.apps.tv.launcherx` _(Updated for R4G)_. Copy in `artefacts/config.xml`.
- [x] Built and installed with `-StockLauncher none -HomeKeyService`; HomeKeyService enabled
- [ ] A real Home press, then `mFocusedApp` shows `com.gathin.tvhome`; screenshot
- [ ] Browsehere (`com.tcl.browser`) first in the grid (`tile_menu` Move, or the grid order)
- [ ] Real buttons: Input, Settings, YouTube, mic, Back, volume hold-to-ramp
- [ ] Home pressed while on an HDMI input: note whether launcherx flashes first (#1121 doesn't cover HDMI)
- [ ] After a cold boot, Home is still CleanYourTV. Power-on = Home: if Live TV opens by itself, set `power_on_home`

## Comments

**2026-10-28: installed, Home redirect works with an injected key.**
- Build: `gradlew assembleRelease`, 550,497 B (under the 576 KB gate). `config.xml` diff: dock (7), `columns` 7, `hidden_apps` (5), `live_tv_package` com.realtek.tv, `stock_home_redirect` launcherx, `tile_menu` true. A copy is in `artefacts/config.xml`.
- `build-and-install.ps1 -StockLauncher none -HomeKeyService`: md5 MATCH, `pm install` Success, launcher started, `set-home-activity` "Success". It then threw at the Home check: Home still resolves to launcherx, as on the AR55. It suggested disabling setupwraith; **not done** (ADR 0001: setupwraith owns the saved Wi-Fi). The script process hung after the throw and was stopped. Nothing was disabled.
- HomeKeyService was enabled with the script's own `Enable-Service` command through `tv.py --batch`. `dumpsys accessibility` shows it Bound ("Home button").
- Injected HOME → `mFocusedApp` = `com.gathin.tvhome/.MainActivity` (`shots/L1-home.png`). Health check L1 is in `logs/L1-health.log`.
- Waiting on the owner: the real-remote buttons, Browsehere moved first, a cold boot, and the power-on screen.
