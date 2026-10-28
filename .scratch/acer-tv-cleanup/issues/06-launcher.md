# 06: CleanYourTV launcher on Home

Status: needs-triage
Type: task
Blocked by: 01, 05

Phase 5, per ADR 0001.

## Acceptance
- [ ] `config.xml`: dock = YouTube, Netflix, Prime Video, JioHotstar, Crunchyroll, Spotify, Sony LIV; `columns` 7; Live TV `com.realtek.tv`; `hidden_apps` = com.realtek.tv, play.games, mk.tv.timeclock, apps.tvmanager, creative.fastscreen.tv; `stock_home_redirect` = `com.google.android.apps.tv.launcherx` _(Updated for R4G)_. Copy in `artefacts/config.xml`.
- [ ] Built and installed with `-StockLauncher none -HomeKeyService`; HomeKeyService enabled
- [ ] A real Home press, then `mFocusedApp` shows `com.gathin.tvhome`; screenshot
- [ ] Browsehere (`com.tcl.browser`) first in the grid (`tile_menu` Move, or the grid order)
- [ ] Real buttons: Input, Settings, YouTube, mic, Back, volume hold-to-ramp
- [ ] Home pressed while on an HDMI input: note whether launcherx flashes first (#1121 doesn't cover HDMI)
- [ ] After a cold boot, Home is still CleanYourTV. Power-on = Home: if Live TV opens by itself, set `power_on_home`

## Comments
