# PRD: Clean the Acer TV, keep it a normal Android TV

Status: ready-for-human
Owner: Karthik (on the TV) + Claude Code (laptop side)
Plan: `PLAN.md`. Tickets: `issues/`. Board: `BOARD.md`.

## Problem Statement

The Acer AR43GR2851VQD's stock home is full of sponsored rows and partner content, and the
firmware runs SCBC and Google telemetry, ad-personalisation and demo services. I want those gone,
and a clean home screen, without losing anything I use the TV for: Play Store, my streaming apps,
casting, voice search, HDMI and Live TV, firmware updates and Settings.

## Solution

Use the CleanYourTV repo's own tools over network ADB. Back up the TV and write a restore record.
Disable (never uninstall) the ad, telemetry and bloat packages in batches of 10 or fewer, with a
screenshot and a health check after each. Install the CleanYourTV launcher with the dock below,
taking the Home button through its Home-button helper while the stock launcher stays enabled
(ADR 0001). Verify everything, close ADB, and leave a runbook with the one-line restore.

### Decisions from the owner (2026-10-28)

- **Dock, 7 slots in this order:** YouTube, Netflix, Prime Video, JioHotstar, Crunchyroll, Spotify,
  Sony LIV. Browsehere goes first in the grid (it doesn't fit in the dock).
- **Keep:** Google Assistant, firmware updates, Audio Link, YouTube Music, TalkBack (owner unsure,
  so kept), and every installed streaming app.
- **Disable:** FastCast and SCast (only Chromecast is used), Play Movies, the Colors screensaver.
- **The TV is on Wi-Fi**, not USB Ethernet.
- **If the probe shows the Google TV variant:** stop and re-plan (owner's answer).
- **Tracker:** local markdown plus `git init`, mirrored to a **private** GitHub repo. `artefacts/`
  (device identifiers) and the `cleanyourtv/` clone are git-ignored (owner's answer).
- **Power-on screen:** Home. If the firmware opens Live TV by itself at power-on, set
  `power_on_home` (needs HomeKeyService, which ADR 0001 already enables). Never `boot_to_live_tv`.
- **Optional extras:** none (no Private DNS, no theme, no clock screensaver).

## User Stories

1. As the owner, I want sponsored and recommendation rows gone from Home, so that Home shows only my apps.
2. As the owner, I want my seven favourite apps in the dock in my order, so that one press starts what I watch most.
3. As the owner, I want every other installed app in the grid, Browsehere first, so that nothing I installed is hidden.
4. As the owner, I want new apps from Play Store to appear in the grid automatically, so that I never have to re-run anything after installing.
5. As the owner, I want Play Store installs and updates to keep working, so that my apps stay current.
6. As the owner, I want Google sign-in to keep working, so that my apps and Play account stay linked.
7. As the owner, I want Netflix, Prime Video, JioHotstar, YouTube, Crunchyroll, Spotify, Sony LIV and YouTube Music to play, so that the cleanup costs me no content.
8. As the owner, I want to cast from my phone with Chromecast, so that casting still works.
9. As the owner, I want voice search on the remote's mic button, so that I can still search by voice.
10. As the owner, I want each HDMI input, AV and Live TV reachable from the Inputs button, so that my other devices still work.
11. As the owner, I want the remote's Home, Back, Input, Settings, YouTube and volume buttons to behave as before (volume still ramps when held), so that the remote feels unchanged.
12. As the owner, I want Bluetooth remote pairing, the keyboard and picture/sound settings untouched, so that I can still configure the TV.
13. As the owner, I want firmware updates to keep arriving, so that the TV stays patched.
14. As the owner, I want telemetry, ad-personalisation and demo services off, so that the TV stops phoning home.
15. As the owner, I want every change recorded before it happens, so that one command can put the TV back.
16. As the owner, I want changes made in small batches with a check after each, so that a breakage is caught at once and tied to its batch.
17. As the owner, I want the TV to keep the new Home and the cleanup after a cold boot, so that it lasts.
18. As the owner, I want network debugging closed afterwards, so that nobody on my Wi-Fi can get a shell on the TV.
19. As the owner, I want a runbook covering restore, the after-firmware-update check and re-enabling debugging, so that I can maintain it without this session.
20. As the owner, I want screenshots, lists, logs and records kept in this project folder, so that I have evidence of what was done.

## Implementation Decisions

- The tools are the cloned repo's PowerShell scripts (`disable.ps1`, `restore.ps1`,
  `build-and-install.ps1`, `theme.ps1`) and Python tools run from the venv (ADR 0002).
- The applied list `artefacts/acer-debloat.txt` grows one batch at a time. The approved master is
  `artefacts/acer-debloat-final.txt` (ADR 0003).
- The stock launcher stays enabled. The launcher sets `stock_home_redirect =
  com.google.android.tvlauncher` and runs HomeKeyService (ADR 0001).
- `config.xml` is the only file changed inside `cleanyourtv/`.
- **Gate:** if the probe shows device `R4_GTV` or `launcherx`, execution stops and this PRD is re-planned.

## Testing Decisions

- **Seam:** the TV as seen over ADB, through `scripts/health-check.ps1`. It asserts that every
  must-keep package is enabled, that the expected disabled set matches, that Home is focused, and
  that Play Store and one streaming app come to the front.
- It is proven red once (a bogus must-keep package makes it fail), then green on the untouched TV,
  and it gates every batch.
- An injected key is not proof for remote buttons: the owner presses the real buttons (Phase 6).

## Out of Scope

- Uninstalling anything, rooting, flashing.
- Changing upstream `cleanyourtv/` code, docs or tests, or contributing a list upstream (could follow later).
- Private DNS, themes and the clock screensaver (the owner declined all three).

## Further Notes

The source of truth is upstream `examples/acer-ar55ar2851udpro/` (the AR55, Android TV 14, build
UKR1.260308) and `docs/devices/acer-r4g.md` (the Google TV variant).

## Comments

**2026-10-28: re-plan needed (ticket 02).** The TV is the Google TV variant (`R4_GTV`, launcherx), not the Android TV AR55 this plan was built on. The R4G firmware re-enables about 20 packages at every cold boot, and launcherx and setupwraith must both stay enabled. ADR 0001's approach still applies, but with `stock_home_redirect = com.google.android.apps.tv.launcherx`. The debloat list and the restore's stock-launcher argument must change. Waiting on the owner's choice of re-plan before amending the PRD.
