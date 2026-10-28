# Health check: the pass/fail gate after every debloat batch (see CONTEXT.md, "Health check").
# Read-only apart from pressing HOME and opening apps, which is what a person would do with the remote.
#
# Usage (from the project root):
#   scripts\health-check.ps1 [-Label B1] [-App com.netflix.ninja] [-List artefacts\acer-debloat.txt]
#   scripts\health-check.ps1 -ExtraMustKeep com.example.bogus    # must FAIL: proves the check can go red
# Exit code: 0 all checks passed, 1 at least one failed, 2 the TV could not be reached.
param(
    [string]$Label = 'check',
    [string]$App = 'com.google.android.youtube.tv',
    [string]$List = '',
    [string[]]$ExtraMustKeep = @(),
    [string]$TvHost = $(if ($env:TV_HOST) { $env:TV_HOST } else { '192.168.1.162' })
)
$ErrorActionPreference = 'Continue'
$P = Split-Path -Parent $PSScriptRoot
$py = Join-Path $P 'cleanyourtv\tools\venv\Scripts\python.exe'
$tv = Join-Path $P 'cleanyourtv\tools\tv.py'
$shots = Join-Path $P 'artefacts\shots'
if (-not $List) { $List = Join-Path $P 'artefacts\acer-debloat.txt' }
$env:TV_HOST = $TvHost

# Must be installed AND enabled. Missing counts as a failure: all present on this TV (Acer R4G, discovery
# 2026-10-28, artefacts/lists/packages-all.txt).
$required = @(
    'com.android.vending', 'com.google.android.gms', 'com.google.android.gsf',   # Play
    'com.google.android.katniss',                                                 # voice / mic button
    'com.google.android.apps.mediashell',                                         # Chromecast
    'com.google.android.apps.tv.launcherx',                                       # stock Home (ADR 0001)
    'com.google.android.tungsten.setupwraith',                                    # owns a saved Wi-Fi network
    'com.android.tv.settings', 'com.android.systemui',                            # Settings, system UI
    'com.realtek.tv.passthrough', 'com.realtek.tv',                               # HDMI/AV inputs, Live TV app
    'com.realtek.dtv', 'com.realtek.tv.atv', 'com.mk.service.tvmidware',          # tuner inputs, TV middleware
    'com.apps.ota', 'com.apps.authota', 'com.realsil.ota', 'com.google.android.tv.dfuservice',   # OTA
    'com.google.android.inputmethod.latin',                                       # keyboard
    'com.realtek.leanbacklauncher.partnercustomizer',                             # Inputs button
    'com.realtek.keyinterceptserver', 'com.realtek.android.globalkeyhandler',     # remote keys
    'com.apps.android.globalkeyhandler', 'com.apps.smartkey', 'com.apps.virtualkey', 'com.mk.tv.fivekey',
    'com.apps.bluetoothremote', 'com.google.android.tv.remote.service', 'com.google.android.presetup.bluetoothpair',
    'com.google.android.youtube.tv', 'com.google.android.youtube.tvmusic',        # owner's apps (system-installed)
    'com.netflix.ninja', 'com.amazon.amazonvideo.livingroom',
    'com.apps.function.audiolink', 'com.google.android.marvin.talkback'          # kept on the owner's answers
) + $ExtraMustKeep
# Must stay enabled IF installed.
$ifPresent = @(
    'com.realtek.tv.atsc', 'com.realtek.tv.isdb', 'com.realtek.dtmb', 'com.netflix.tokenmanager', 'com.gathin.tvhome'
)

$fail = 0
function Pass([string]$m) { Write-Host "PASS  $m" -ForegroundColor Green }
function Fail([string]$m) { Write-Host "FAIL  $m" -ForegroundColor Red; $script:fail++ }
function Shell([string]$cmd) { $o = & $py -I $tv $cmd 2>$null; if ($LASTEXITCODE -ne 0) { return $null }; return @($o) }
function Pkgs([string]$flags) {
    $o = Shell "pm list packages $flags --user 0"
    if ($null -eq $o) { return $null }
    return @($o | Where-Object { $_ -like 'package:*' } | ForEach-Object { $_.Substring(8).Trim() })
}
# Single quotes for the TV's shell: Windows PowerShell 5.1 strips inner double quotes from native arguments.
function Resumed { (Shell 'dumpsys activity activities | grep -E ''topResumedActivity|mResumedActivity|mFocusedApp''') -join "`n" }

Write-Host "== health check [$Label] on $TvHost =="
$all = Pkgs ''; $enabled = Pkgs '-e'; $third = Pkgs '-3'
if ($null -eq $all -or $null -eq $enabled) { Write-Host 'ERROR  the TV did not answer over ADB' -ForegroundColor Red; exit 2 }

# 1. Must-keep packages
foreach ($p in $required) {
    if ($all -notcontains $p) { Fail "$p is not installed (required)" }
    elseif ($enabled -notcontains $p) { Fail "$p is DISABLED (required)" }
}
foreach ($p in $ifPresent) { if ($all -contains $p -and $enabled -notcontains $p) { Fail "$p is DISABLED (must-keep)" } }
# Every app the owner installed (third-party) stays enabled: streaming apps, Browsehere, etc.
foreach ($p in $third) { if ($enabled -notcontains $p) { Fail "$p (installed app) is DISABLED" } }
# The on-screen keyboard
$ime = (Shell 'settings get secure default_input_method') -join ''
if ($ime -match '^([\w.]+)/') { if ($enabled -notcontains $Matches[1]) { Fail "keyboard $($Matches[1]) is DISABLED" } }
if ($fail -eq 0) { Pass "must-keep packages, $(@($third).Count) installed apps and the keyboard are enabled" }

# 2. The applied list is what is disabled
if (Test-Path $List) {
    $want = Get-Content $List | ForEach-Object { ($_ -replace '#.*$', '').Trim() } | Where-Object { $_ } | ForEach-Object { ($_ -split '\s+')[0] }
    $stillOn = @($want | Where-Object { $enabled -contains $_ })
    if ($stillOn.Count) { Fail "listed but still enabled: $($stillOn -join ', ')" } else { Pass "all $(@($want).Count) listed packages are disabled (or absent)" }
} else { Write-Host "SKIP  no applied list yet ($List)" }

# 3. Home answers
$null = Shell 'input keyevent KEYCODE_HOME'; Start-Sleep -Seconds 3
$r = Resumed
if ($r -match 'com\.gathin\.tvhome|com\.google\.android\.apps\.tv\.launcherx') { Pass "Home is on screen ($([regex]::Match($r, '(com\.gathin\.tvhome|com\.google\.android\.apps\.tv\.launcherx)[^\s}]*').Value))" }
else { Fail "Home did not come up after HOME: $r" }
& $py -I $tv --screenshot (Join-Path $shots "$Label-home.png") 2>$null | Out-Null

# 4. Play Store and one streaming app come to the front
foreach ($pkg in @('com.android.vending', $App)) {
    $null = Shell "monkey -p $pkg -c android.intent.category.LEANBACK_LAUNCHER 1"
    Start-Sleep -Seconds 6
    $r = Resumed
    if ($r -match [regex]::Escape($pkg)) { Pass "$pkg opened" } else { Fail "$pkg did not come to the front: $r" }
    & $py -I $tv --screenshot (Join-Path $shots "$Label-$pkg.png") 2>$null | Out-Null   # Netflix etc. give an empty PNG: normal
    $null = Shell 'input keyevent KEYCODE_HOME'; Start-Sleep -Seconds 2
}

if ($fail -eq 0) { Write-Host "== [$Label] ALL PASSED ==" -ForegroundColor Green; exit 0 }
Write-Host "== [$Label] $fail FAILED: stop and restore this batch ==" -ForegroundColor Red; exit 1
