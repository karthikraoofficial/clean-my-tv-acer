# Board: acer-tv-cleanup

PRD: [.scratch/acer-tv-cleanup/spec.md](.scratch/acer-tv-cleanup/spec.md). Tickets: [.scratch/acer-tv-cleanup/issues/](.scratch/acer-tv-cleanup/issues/).
A ticket moves to **Ready** when every ticket in its `Blocked by:` line is Done.

| Backlog | Ready | In progress | Done |
|---|---|---|---|
| | | 05 Debloat: B1+B2 done, cold-boot check pending | 01 Prerequisites and workspace (e1d7da6) |
| | | | 02 Connect and probe: R4G, re-planned (c9b6244) |
| | | | 03 Backup and baseline (76ba96b) |
| | | | 04 Final list approved (v2) |
| 06 Launcher (← 01, 05) | | | |
| 07 Verify (← 06) | | | |
| 08 Harden and runbook (← 07) | | | |

## Blocking graph

```
01 ─┬─► 02 ─┬─► 03 ─┐
    │       └─► 04 ─┴─► 05 ─► 06 ─► 07 ─► 08
    └───────────────────────────► 06
```
