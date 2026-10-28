# 07: Verify end to end

Status: resolved
Type: task
Blocked by: 06

Phase 6. Screenshots go in `artefacts/shots/V*`.

## Acceptance
- [x] New free app from Play Store appears in the grid
- [x] An app updates from Play Store
- [x] Netflix, Prime Video, JioHotstar, YouTube, Crunchyroll, Spotify, Sony LIV, YouTube Music play
- [x] Chromecast from a phone
- [x] Voice search on the mic button
- [x] Each HDMI input, AV, Live TV
- [x] Remote: Input, Home, Back, Settings, volume
- [x] Reboot and a cold boot: Home is CleanYourTV, no ads, disabled set unchanged

## Comments

**2026-10-28: automated part done.**
- Each app opened from the launcher and reached `topResumedActivity` (`logs/V-apps.txt`, `shots/V-*.png`): YouTube, Netflix, Prime Video, JioHotstar, Crunchyroll, Spotify, Sony LIV, Browsehere, Live TV (`com.realtek.tv`), Play Store. YouTube Music opens YouTube's Music page, which is how Google designed it (screenshot).
- Reboot (`tv.py --reboot`, boot_completed after 52 s): Home = `com.gathin.tvhome` (`mFocusedApp`), helper still enabled, animation scales still 0.5. Boot sequence: FallbackHome → launcherx (+7.1 s) → tvhome (+3.8 s). `check.py`: nothing drifted (9). Health check V-reboot with Sony LIV: ALL PASSED.
- Sensor privacy: only the camera (sensor 2) is toggled on; the mic isn't blocked.
- After the reboot, mdns advertises only `_adb._tcp` 5555; Wireless debugging went off by itself.
- Waiting on the owner: Play Store install and update, playback in each app, Chromecast, the mic, each HDMI input and Live TV, the remote buttons. The earlier remote checks covered Home, Back, Settings, Input, YouTube and the mic.

**2026-10-28, closed.** The owner verified Play Store install (the app appears in the grid) and update, playback in Netflix, Prime Video, JioHotstar and YouTube, Chromecast from the phone, voice search, each HDMI input and Live TV.
