# 0003: Batches grow one applied list, so there is one restore record

Date: 2026-10-28. Status: accepted.

## Context

`disable.ps1` disables everything in the list it is given in one run. The restore record that
`recovery.py` writes is keyed by the list file's absolute path (`recovery-<ip>-<sha1(path)[:8]>.json`):
the first run records the "before" state, and later runs of the same file add only the names the list
gained, with their state before this run. Separate files per batch would mean separate records and
several restore commands.

## Decision

`artefacts/acer-debloat-final.txt` is the approved list, split into batch sections. Each batch is
applied by appending its lines to `artefacts/acer-debloat.txt` and running `disable.ps1` on that file.
Never rename or move `acer-debloat.txt`: the record is keyed by its path.

## Consequences

- One command restores everything: `restore.ps1 artefacts\acer-debloat.txt`.
- Rolling back one batch is a per-package `pm enable --user 0`, then removing those lines from the
  applied list. The record keeps their original state, which is harmless.
- After a firmware update, `check.py artefacts\acer-debloat.txt` compares the TV with the full applied list.
