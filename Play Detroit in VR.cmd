@echo off
setlocal EnableExtensions
cd /d "%~dp0"

rem ===========================================================================
rem  DETROIT: BECOME HUMAN - VR MOD
rem
rem  Put this whole DETROIT_VR_MOD folder inside your Detroit game folder (the
rem  one containing DetroitBecomeHuman.exe) and run this file.
rem
rem  Nothing in the game folder is replaced or overwritten. The mod launches the
rem  game and injects itself; the only file it edits is GraphicOptions.JSON, and
rem  a copy of the original is kept before the first change.
rem ===========================================================================

rem --- how many frames per second the game is allowed ------------------------
rem  Detroit's video menu only offers two choices, but the value it stores is an
rem  INDEX into a longer list, and the higher entries are reachable only from the
rem  config file:
rem      1 = the menu's 30/60      2 = 90 fps      3 = 144 fps      4 = unlimited
rem  At the menu's 30 the frame interval measures a pinned 33.3 ms and SteamVR
rem  shows a solid red graph. 2 (90 fps) matches a 90 Hz headset.
set FPS_CAP_INDEX=2

rem --- keeping the cap once it is set -----------------------------------------
rem  Detroit rewrites its config whenever you open the video menu, which would
rem  put the cap back. With this on, the config is made read-only so the menu
rem  cannot. NOTE: while it is on, the game cannot save ANY graphics option -
rem  resolution and brightness included. Set it to 0 to change those, then back.
set LOCK_SETTINGS=0

echo(
echo  ================================================================
echo    DETROIT: BECOME HUMAN  -  VR MOD
echo  ================================================================
echo(

rem --- 1. are we in the right place? -----------------------------------------
rem  "%~dp0.." would read as "...\DETROIT_VR_MOD\.." everywhere it is printed,
rem  so it is expanded to a real absolute path first.
for %%I in ("%~dp0..") do set "GAME_DIR=%%~fI"

rem  Not written as an  if ... ( ... )  block: GAME_DIR is echoed unquoted, and a
rem  game folder under "C:\Program Files (x86)" puts a ")" into the block while
rem  cmd is still parsing it, which closes the block early and kills the script
rem  with "... was unexpected at this time" - whether or not the branch is taken.
if exist "%GAME_DIR%\DetroitBecomeHuman.exe" goto :gamefound
echo   [X] DetroitBecomeHuman.exe was not found in:
echo       %GAME_DIR%
echo(
echo   Move the whole DETROIT_VR_MOD folder INTO your Detroit game folder -
echo   the one that contains DetroitBecomeHuman.exe - and run this again.
echo(
pause
exit /b 1
:gamefound

if not exist "%~dp0detroit_vr_launcher.exe" (
  echo   [X] detroit_vr_launcher.exe is missing from this folder.
  echo       Re-extract the mod; some files did not copy.
  echo(
  pause
  exit /b 1
)

echo   Game folder: %GAME_DIR%
set "CFG=%GAME_DIR%\GraphicOptions.JSON"
set "MOD_DIR=%~dp0."

rem --- 2. Steam's app id ------------------------------------------------------
rem  A Steam copy launched directly, rather than from Steam, has no idea which app
rem  it is. Retail is wrapped in Steam's DRM stub and reacts by asking Steam to
rem  start the game AGAIN - a second process, without the mod in it - and quietly
rem  exits, so the game runs flat while the mod reports a perfect start-up in a
rem  process that is already gone. The demo is not wrapped and fails outright with
rem  "Steam must be running to play this game (SteamAPI_Init() failed)".
rem
rem  steam_appid.txt next to the exe answers the question and both stop. The id is
rem  read out of Steam's own appmanifest for this folder, so it is right for retail,
rem  for the demo, and for any library folder on any drive - nothing is hardcoded.
rem  Epic copies have no steam_api64.dll and are skipped; they need none of this.
if not exist "%GAME_DIR%\steam_api64.dll" goto :appid_done
if exist "%GAME_DIR%\steam_appid.txt" goto :appid_done
rem  The .acf is read by splitting on the quote character rather than matching a
rem  pattern against it: a literal \" inside this block unbalances the quotes cmd
rem  counts while joining the ^ continuations, and the whole command is then lost
rem  without a word of complaint.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$game = $env:GAME_DIR;" ^
  "$common = Split-Path $game -Parent;" ^
  "if ((Split-Path $common -Leaf) -ne 'common') { Write-Host '   [!] Steam app id: not inside a Steam library - skipped'; exit }" ^
  "$steamapps = Split-Path $common -Parent;" ^
  "$dir = Split-Path $game -Leaf;" ^
  "$id = $null;" ^
  "foreach ($m in Get-ChildItem -LiteralPath $steamapps -Filter 'appmanifest_*.acf' -ErrorAction SilentlyContinue) {" ^
  "  $raw = Get-Content -LiteralPath $m.FullName -Raw -ErrorAction SilentlyContinue;" ^
  "  if (-not $raw) { continue }" ^
  "  $p = $raw.Split([char]34); $found = ''; $app = '';" ^
  "  for ($i = 0; $i -lt $p.Length - 2; $i++) {" ^
  "    if ($p[$i] -eq 'installdir') { $found = $p[$i+2] }" ^
  "    if ($p[$i] -eq 'appid') { $app = $p[$i+2] } }" ^
  "  if ($found -eq $dir -and $app -match '^[0-9]+$') { $id = $app; break } }" ^
  "if (-not $id) { Write-Host '   [!] Steam app id: no appmanifest matched this folder - skipped'; exit }" ^
  "$out = Join-Path $game 'steam_appid.txt';" ^
  "[IO.File]::WriteAllText($out, $id, (New-Object Text.UTF8Encoding $false));" ^
  "if (Test-Path -LiteralPath $out) {" ^
  "  New-Item -ItemType File -Path (Join-Path $env:MOD_DIR 'steam_appid.created') -Force | Out-Null;" ^
  "  Write-Host ('   Steam app id ' + $id + ' written to steam_appid.txt, so the game stays in this process') }" ^
  "else { Write-Host '   [!] Steam app id: could not write steam_appid.txt - skipped' }"
:appid_done

rem --- 3. frame cap -----------------------------------------------------------
if exist "%CFG%" (
  call :applycap
) else (
  echo(
  echo   ============================================================
  echo     FRAME RATE CAP NOT APPLIED YET
  echo   ============================================================
  echo     GraphicOptions.JSON does not exist yet. Detroit only writes
  echo     it after it has run once, so on a brand new install there
  echo     is nothing to edit.
  echo(
  echo     Left alone, Detroit runs capped at 30 or 60 fps and VR feels
  echo     bad - the SteamVR graph goes solid red.
  echo(
  echo     THIS IS HANDLED FOR YOU: play now, then QUIT the game. The
  echo     cap is set automatically as you exit, and takes effect from
  echo     your next launch.
  echo   ============================================================
  echo(
  pause
)

echo(
echo   Before continuing:
echo     - start SteamVR ^(or your OpenXR runtime^) and put the headset on
echo     - make sure the headset is tracking
echo(
echo   In game:
echo     - F6            recenter your view
echo     - both sticks   press together to open the VR settings panel
echo     - play with your normal gamepad or keyboard
echo(
pause

"%~dp0detroit_vr_launcher.exe" --game "%GAME_DIR%\DetroitBecomeHuman.exe"
set "LAUNCH_RESULT=%errorlevel%"

rem --- 4. after the session ---------------------------------------------------
rem  On a first-ever run the config did not exist beforehand. Detroit has written
rem  it by now, so the cap is applied here and is in force from the next launch.
if exist "%CFG%" (
  echo(
  echo   Frame rate cap, for next launch:
  call :applycap
)

rem  detroit_vr_launcher.exe hands back whatever Detroit itself exited with, so a
rem  non-zero code is normally just how the game ends and says nothing about the
rem  mod. Only 1-5 are the launcher's own, and in every one of those it never got
rem  the game running at all - those are the ones worth a log.
rem  Detroit's own quit code is 53, not 0, so anything outside 1-5 is a normal
rem  session and is passed over in silence.
if "%LAUNCH_RESULT%"=="0" goto :finished
if %LAUNCH_RESULT% LSS 1 goto :finished
if %LAUNCH_RESULT% GTR 5 goto :finished

echo(
echo   The VR launcher could not start the game ^(error %LAUNCH_RESULT%^).
echo(
if exist "%~dp0profiles\debug_log.flag" goto :haselog
echo   There is no log unless you ask for one. To capture what happened,
echo   create an empty file named  profiles\debug_log.flag  and run this
echo   again; detroit_vr_debug.log then appears next to this file.
goto :finished

:haselog
echo   Logging is already on, so the details are in:
echo       detroit_vr_debug.log
echo   Delete profiles\debug_log.flag afterwards - the log grows large.

:finished
echo(
pause
endlocal
exit /b 0


rem ===========================================================================
rem  :applycap - set FRAME_RATE_LIMIT, then read it back and prove it took.
rem  Called before launching, and again afterwards for the first-run case.
rem ===========================================================================
:applycap
if not exist "%CFG%.vrmod-backup" copy /y "%CFG%" "%CFG%.vrmod-backup" >nul
rem The config is left read-only between runs, so clear that before rewriting.
attrib -r "%CFG%" >nul 2>&1
rem  Written with NO byte-order mark. Detroit's own file has none, and
rem  PowerShell's Set-Content -Encoding utf8 adds one, which makes the file
rem  unparseable - the game then silently falls back to its defaults and ignores
rem  whatever was written here. Hence WriteAllText with UTF8Encoding $false, and
rem  the value is read back off disk afterwards rather than assumed.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$p = $env:CFG;" ^
  "$t = [IO.File]::ReadAllText($p);" ^
  "if ($t.Length -gt 0 -and $t[0] -eq [char]0xFEFF) { $t = $t.Substring(1) }" ^
  "if ($t -notmatch '\"FRAME_RATE_LIMIT\"\s*:\s*(\d+)') { Write-Host '   [!] FRAME_RATE_LIMIT not in the config - cap NOT applied'; exit }" ^
  "$was = $Matches[1];" ^
  "$t = $t -replace '(\"FRAME_RATE_LIMIT\"\s*:\s*)\d+', ('${1}' + $env:FPS_CAP_INDEX);" ^
  "[IO.File]::WriteAllText($p, $t, (New-Object Text.UTF8Encoding $false));" ^
  "$back = [IO.File]::ReadAllText($p);" ^
  "$bom = ($back.Length -gt 0 -and $back[0] -eq [char]0xFEFF);" ^
  "if ($back -match '\"FRAME_RATE_LIMIT\"\s*:\s*(\d+)') { $now = $Matches[1] } else { $now = '?' }" ^
  "$good = $false; try { $null = (ConvertFrom-Json $back); $good = (($now -eq $env:FPS_CAP_INDEX) -and (-not $bom)) } catch { }" ^
  "if ($good) { Write-Host ('   Frame cap: ' + $was + ' -> ' + $now + '  (2 = 90 fps, 4 = unlimited)   verified on disk') }" ^
  "else { Copy-Item ($p + '.vrmod-backup') $p -Force; Write-Host '   [!] Frame cap write FAILED - your original config was restored' }"

if "%LOCK_SETTINGS%"=="1" (
  attrib +r "%CFG%" >nul 2>&1
  echo   Config locked so the in-game video menu cannot undo the cap.
)
exit /b 0
