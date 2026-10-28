# 07: Verify end to end

Status: in-progress
Type: task
Blocked by: 06

Phase 6. Screenshots go in `artefacts/shots/V*`.

## Acceptance
- [ ] New free app from Play Store appears in the grid
- [ ] An app updates from Play Store
- [ ] Netflix, Prime Video, JioHotstar, YouTube, Crunchyroll, Spotify, Sony LIV, YouTube Music play
- [ ] Chromecast from a phone
- [ ] Voice search on the mic button
- [ ] Each HDMI input, AV, Live TV
- [ ] Remote: Input, Home, Back, Settings, volume
- [ ] Reboot and a cold boot: Home is CleanYourTV, no ads, disabled set unchanged

## Comments

**2026-10-28: automated part done.**
- Each app opened from the launcher and reached `topResumedActivity` (`logs/V-apps.txt`, `shots/V-*.png`): YouTube, Netflix, Prime Video, JioHotstar, Crunchyroll, Spotify, Sony LIV, Browsehere, Live TV (`com.realtek.tv`), Play Store. YouTube Music opens YouTube's Music page, which is how Google designed it (screenshot).
- Reboot (`tv.py --reboot`, boot_completed after 52 s): Home = `com.gathin.tvhome` (`mFocusedApp`), helper still enabled, animation scales still 0.5. Boot sequence: FallbackHome → launcherx (+7.1 s) → tvhome (+3.8 s). `check.py`: nothing drifted (9). Health check V-reboot with Sony LIV: ALL PASSED.
- Sensor privacy: only the camera (sensor 2) is toggled on; the mic isn't blocked.
- After the reboot, mdns advertises only `_adb._tcp` 5555; Wireless debugging went off by itself.
- Waiting on the owner: Play Store install and update, playback in each app, Chromecast, the mic, each HDMI input and Live TV, the remote buttons. The earlier remote checks covered Home, Back, Settings, Input, YouTube and the mic.
