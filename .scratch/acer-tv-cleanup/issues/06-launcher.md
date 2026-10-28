# 06: CleanYourTV launcher on Home

Status: needs-triage
Type: task
Blocked by: 01, 05

Phase 5, per ADR 0001.

## Acceptance
- [ ] `config.xml`: dock = YouTube, Netflix, Prime Video, JioHotstar, Crunchyroll, Spotify, Sony LIV; `columns` 7; Live TV `com.apps.livetv` (hidden from the grid); `stock_home_redirect` tvlauncher. Copy in `artefacts/config.xml`.
- [ ] Built and installed with `-StockLauncher none -HomeKeyService`; HomeKeyService enabled
- [ ] A real Home press, then `mFocusedApp` shows `com.gathin.tvhome`; screenshot
- [ ] Browsehere first in the grid (`tile_menu` Move, or the grid order)
- [ ] Real buttons: Input, Settings, YouTube, mic, Back, volume hold-to-ramp
- [ ] After a cold boot, Home is still CleanYourTV. Power-on = Home: if Live TV opens by itself, set `power_on_home`

## Comments
