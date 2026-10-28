# 0001: The stock launcher stays enabled; Home reaches CleanYourTV through HomeKeyService

Date: 2026-10-28. Status: accepted. _(Updated 2026-10-28: the TV is the Google TV R4G, so the stock launcher is
`com.google.android.apps.tv.launcherx`, not `tvlauncher`. See ADR 0004.)_

## Context

The owner's original plan disabled the stock launcher once the new launcher answered HOME. On this
platform that is unsafe:
- On the Android TV sibling (upstream `examples/acer-ar55ar2851udpro/`), `set-home-activity` does not
  stick ("Result set changed, dropping preferred activity"). Home stays on the stock launcher, so the
  Home guard never lets it go.
- On the Google TV R4G (this TV, upstream `docs/devices/acer-r4g.md`), the firmware re-enables setupwraith
  at every cold boot. Its `.RecoveryActivity` (HOME priority 1) outranks any third-party launcher and
  loops looking for a disabled launcherx: Home goes black.

## Decision

Keep `com.google.android.apps.tv.launcherx` and `com.google.android.tungsten.setupwraith` enabled. Install
the launcher with `-StockLauncher none -HomeKeyService`, and set `stock_home_redirect =
com.google.android.apps.tv.launcherx` in `config.xml`. When launcherx's home comes up, at boot or after a
Home press, HomeKeyService sends the TV to CleanYourTV (upstream #1116, fixed by #1121 on 2026-10-23).

## Consequences

- Home is a redirect, not the system default. Success is checked with
  `dumpsys activity activities | grep mFocusedApp` after a real Home press and after a cold boot, not with
  `resolve-activity`.
- #1121 does not cover an HDMI input: Home pressed from HDMI may show launcherx briefly before the redirect.
  That's accepted; check it in ticket 07.
- `am force-stop com.gathin.tvhome` turns the helper off until it is re-enabled (Settings → Accessibility).
- Restore is simpler: the stock launcher never left.
- _(Added 2026-10-28)_ `home_long_press_home=true`: HomeKeyService consumes the Home key and opens CleanYourTV
  on key-up. A root firmware process still starts launcherx's HOME intent (`from uid 0`), so Google TV shows for
  about 0.3 s. That is the floor without root. A held Home no longer gives Google TV's long-press action.
