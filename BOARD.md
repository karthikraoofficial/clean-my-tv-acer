# Board: acer-tv-cleanup

PRD: [.scratch/acer-tv-cleanup/spec.md](.scratch/acer-tv-cleanup/spec.md). Tickets: [.scratch/acer-tv-cleanup/issues/](.scratch/acer-tv-cleanup/issues/).
A ticket moves to **Ready** when every ticket in its `Blocked by:` line is Done.

| Backlog | Ready | In progress | Done |
|---|---|---|---|
| 03 Backup and baseline (← 02) | 02 Connect and probe (needs the owner at the TV) | 01 Prerequisites and workspace | |
| 04 Final list approved (← 02) | | | |
| 05 Debloat in batches (← 03, 04) | | | |
| 06 Launcher (← 01, 05) | | | |
| 07 Verify (← 06) | | | |
| 08 Harden and runbook (← 07) | | | |

## Blocking graph

```
01 ─┬─► 02 ─┬─► 03 ─┐
    │       └─► 04 ─┴─► 05 ─► 06 ─► 07 ─► 08
    └───────────────────────────► 06
```
