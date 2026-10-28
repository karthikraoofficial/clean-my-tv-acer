# 01: Prerequisites and workspace

Status: resolved
Type: task
Blocked by: none

Phase 0 of `PLAN.md`. Laptop only; the TV is not touched.

## Acceptance
- [x] `cleanyourtv/` cloned; `tools/venv` created; `requirements.txt` installed; `tv.py --help` runs
- [x] `artefacts/{backup,lists,shots,records,logs}` and `scripts/` exist
- [x] JDK 17.0.20.1 (`JAVA_HOME`), Android SDK platform 34, build-tools 34.0.0, platform-tools 1.0.41 (`ANDROID_HOME`)
- [x] Tracker (`docs/agents/`), PRD (`spec.md`), tickets, `BOARD.md`, `CONTEXT.md`, ADRs 0001–0003, project `CLAUDE.md`, `README.md`
- [x] `scripts/health-check.ps1` written and parses cleanly (proven red/green against the TV in 03)
- [x] `git init`, first commit, private GitHub repo created and pushed (artefacts/ and cleanyourtv/ ignored)

## Comments

**2026-10-28, closed in e1d7da6.** Prerequisites were installed per-user (no admin prompt): Temurin 17.0.20.1, cmdline-tools then `sdkmanager` for platform 34, build-tools 34.0.0 and platform-tools (adb 1.0.41). Upstream clone at 095b71ad. Pushed to the private repo karthikraoofficial/clean-my-tv-acer; `artefacts/` (except the two debloat lists) and `cleanyourtv/` are ignored.
