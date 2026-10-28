# 0001: The stock launcher stays enabled; Home reaches CleanYourTV through HomeKeyService

Date: 2026-10-28. Status: accepted (to be confirmed on the TV in ticket 05).

## Context

The owner's original plan disabled `com.google.android.tvlauncher` once the new launcher answered HOME.
On the tested sibling model (upstream `examples/acer-ar55ar2851udpro/`, same Realtek rtd2851m platform
and build), `cmd package set-home-activity` does not stick: Android drops the preference ("Result set
changed, dropping preferred activity") and Home stays on tvlauncher. So the new launcher never answers
HOME, and the Home guard (correctly) never lets the stock launcher go.

## Decision

Keep tvlauncher enabled. Install the launcher with `-StockLauncher none -HomeKeyService` and
`stock_home_redirect = com.google.android.tvlauncher` in `config.xml`, so the Home button lands on
CleanYourTV. Disable `com.google.android.tvrecommendations` so the stock home, if seen, has no
sponsored rows.

## Consequences

- Home is a redirect, not the system default. Success is checked with `dumpsys activity activities | grep mFocusedApp`
  after a real Home press and after a cold boot, not with `resolve-activity`.
- `am force-stop com.gathin.tvhome` turns the helper off until it is re-enabled (Settings → Accessibility).
- Restore is simpler: the stock launcher never left.
- If the probe shows `set-home-activity` does stick on this TV, revisit this ADR rather than
  silently switching approach.
