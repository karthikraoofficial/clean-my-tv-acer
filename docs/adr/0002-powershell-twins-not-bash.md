# 0002: Use the repo's PowerShell scripts, not the `.sh` ones

Date: 2026-10-28. Status: accepted.

## Context

The plan named `tools/disable.sh` and `launcher/build-and-install.sh`. On this laptop the `bash` first
on PATH is `C:\WINDOWS\system32\bash.exe`, which is WSL Ubuntu. Run there, the scripts would look for
`tools/venv/bin/python` (the Windows venv has `Scripts\python.exe`) and would run on WSL's network.
Upstream ships a PowerShell version of every script with the same guards (core-package refusal, Home
guard, setupwraith Wi-Fi guard, TV-input guard, `recovery.py --save` before any change).

## Decision

Use `tools\disable.ps1`, `tools\restore.ps1`, `tools\theme.ps1` and `launcher\build-and-install.ps1`,
run with `powershell -ExecutionPolicy Bypass -File`. Run the Python tools with
`cleanyourtv\tools\venv\Scripts\python.exe -I`.

## Consequences

The runbook's one-line restore is the `.ps1` form. Upstream docs that show `.sh` commands map
one-to-one to the `.ps1` twin.
