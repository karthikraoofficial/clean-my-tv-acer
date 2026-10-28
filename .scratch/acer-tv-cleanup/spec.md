# PRD: Clean the Acer TV, keep it a normal Google TV

Status: ready-for-human
Owner: Karthik (on the TV) + Claude Code (laptop side)
Plan: `PLAN.md`. Tickets: `issues/`. Board: `BOARD.md`.

## Problem Statement

The Acer AR43GR2851VQD's (Acer R4G, Google TV 14) stock home is full of sponsored rows and partner content, and the
firmware runs SCBC and Google telemetry, ad-personalisation and demo services. I want those gone,
and a clean home screen, without losing anything I use the TV for: Play Store, my streaming apps,
casting, voice search, HDMI and Live TV, firmware updates and Settings.

## Solution

Use the CleanYourTV repo's own tools over network ADB. Back up the TV and write a restore record.
Disable (never uninstall) the ad, telemetry and bloat packages **that stay disabled across a cold boot
on this firmware**, in batches of 10 or fewer, with a screenshot and a health check after each
_(Updated: lasting debloat only, ADR 0004)_. Bloat the firmware turns back on at every cold boot is left
enabled but hidden from the new launcher's grid. Install the CleanYourTV launcher with the dock below,
taking the Home button through its Home-button helper while the stock Google TV launcher (launcherx)
and the setup wizard stay enabled (ADR 0001). Verify everything, close ADB, and leave a runbook with the one-line restore.

### Decisions from the owner (2026-10-28)

- **Dock, 7 slots in this order:** YouTube, Netflix, Prime Video, JioHotstar, Crunchyroll, Spotify,
  Sony LIV. Browsehere goes first in the grid (it doesn't fit in the dock).
- **Keep:** Google Assistant, firmware updates, Audio Link, YouTube Music, TalkBack (owner unsure,
  so kept), and every installed streaming app.
- **Disable:** FastCast and SCast (only Chromecast is used), Play Movies, the Colors screensaver.
  _(Updated: on this TV, FastCast and SCast come back at every cold boot, so they're hidden from the grid
  instead (FastCast has the icon); Play Movies isn't installed; the Colors screensaver was already disabled.)_
- **The TV is on Wi-Fi**, not USB Ethernet.
- **If the probe shows the Google TV variant:** stop and re-plan (owner's answer). _(Updated: it did. Re-plan
  chosen: lasting debloat + launcher via the Home redirect, ADR 0004.)_
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
  com.google.android.apps.tv.launcherx` and runs HomeKeyService (ADR 0001) _(Updated: was tvlauncher)_.
- _(Added)_ The list holds only packages that stay disabled across a cold boot. Unverified ones are confirmed by a
  cold boot after the last batch, and dropped if they return (ADR 0004).
- _(Added)_ `config.xml`: `live_tv_package = com.realtek.tv`, and `hidden_apps` = `com.realtek.tv`,
  `com.google.android.play.games`, `com.mk.tv.timeclock`, `com.apps.tvmanager`, `com.creative.fastscreen.tv`.
  Browsehere is `com.tcl.browser`.
- _(Added)_ Restore passes the Google TV launcher: `restore.ps1 ... -Stock com.google.android.apps.tv.launcherx`.
- `config.xml` is the only file changed inside `cleanyourtv/`.
- **Gate:** if the probe shows device `R4_GTV` or `launcherx`, execution stops and this PRD is re-planned. _(It did: ticket 02.)_

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

**2026-10-28: PRD amended for the R4G (summary).** The owner chose a lasting debloat plus the launcher, and
read-only discovery ran. Changes:
- The list shrank to 10 packages (6 + 4) that persist or are still to be verified. The junk the firmware turns back on at boot is hidden from the grid instead.
- The redirect target is launcherx, and setupwraith stays (it owns a saved Wi-Fi network).
- The health check's must-keep set now uses this TV's real package names (`com.realtek.tv.passthrough`,
  `com.realtek.tv`, the tuner inputs, and the key handlers).
- New ADR 0004; ADR 0001 updated.

**2026-10-28: debloat done (ticket 05).** 9 packages are disabled and survive a cold boot. partnersetup turned out to be boot-reset and was dropped. The PRD's user stories 14–17 are met for the debloat half; next is the launcher (ticket 06).

**2026-10-28: owner follow-ups after the launcher went in.** (1) Google TV flashes on Home: it is started by a root firmware process, so it can be shortened (1.6 s → ~0.8 s with `home_long_press_home`) but not removed without root, which is out of scope. (2) Boot takes 48 s: about 29 s is firmware/Android core, which we can't touch. `boot_count=523` shows the TV does a full boot on every power-on, so the fix is a power setting (standby instead of shutdown), not more debloating. Pending the owner's check.
