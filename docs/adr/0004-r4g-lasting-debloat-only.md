# 0004: On the R4G, disable only what stays disabled; hide the rest from the grid

Date: 2026-10-28. Status: accepted (owner's choice after the probe in ticket 02).

## Context

The probe showed this TV is the Acer R4G (MOKA `R4_GTV`, Google TV 14, `UKR1.260308/5597`), not the
Android TV AR55 the first plan was built on. Upstream `docs/devices/acer-r4g.md` documents that its modified
`com.android.tv.settings` re-enables a hard-coded list of about 60 packages at every cold boot, setupwraith
among them. An owner who disabled launcherx got a black Home after a power cut.

The owner was offered three options: a lasting debloat plus the launcher; a lasting debloat only; or the full
list, accepting that part of it comes back at each cold boot. They chose the first.

## Decision

- List only packages seen to stay disabled across cold boots on the R4G, plus packages not on the firmware's
  known list. The latter are confirmed by a cold boot after the last batch; any that return are dropped.
- Never list launcherx or setupwraith. The Home redirect target is `com.google.android.apps.tv.launcherx` (ADR 0001).
- Packages that come back and have an icon (Play Games, World Clock, TV Manager, FastCast) are hidden from the
  CleanYourTV grid with `hidden_apps`. That needs no ADB and survives reboots.

## Consequences

- The disabled set is smaller (10 packages) than the AR55's 28. SCBC's gdpr agent, Google feedback, the
  demo stickers, SCast and FastCast keep running.
- `check.py` after a cold boot should report no drift. If it does, the list is wrong, not the TV.
- Restore passes the Google TV launcher: `restore.ps1 ... -Stock com.google.android.apps.tv.launcherx`.
