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

rem --- desktop shortcut ------------------------------------------------------
rem  Creates (or refreshes) a "Detroit VR" shortcut on your desktop pointing at
rem  this launcher, using the game's own icon. Set to 0 if you would rather not
rem  have one. The uninstaller removes it either way.
set CREATE_SHORTCUT=1

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

if not exist "%GAME_DIR%\DetroitBecomeHuman.exe" (
  echo   [X] DetroitBecomeHuman.exe was not found in:
  echo       %GAME_DIR%
  echo(
  echo   Move the whole DETROIT_VR_MOD folder INTO your Detroit game folder -
  echo   the one that contains DetroitBecomeHuman.exe - and run this again.
  echo(
  pause
  exit /b 1
)

if not exist "%~dp0detroit_vr_launcher.exe" (
  echo   [X] detroit_vr_launcher.exe is missing from this folder.
  echo       Re-extract the mod; some files did not copy.
  echo(
  pause
  exit /b 1
)

echo   Game folder: %GAME_DIR%
set "CFG=%GAME_DIR%\GraphicOptions.JSON"

rem --- 2. frame cap -----------------------------------------------------------
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

rem --- 3. desktop shortcut ----------------------------------------------------
if not "%CREATE_SHORTCUT%"=="1" goto :launch
set "LNK_TARGET=%~dp0Play Detroit in VR.cmd"
set "LNK_WORKDIR=%~dp0"
set "LNK_ICON=%GAME_DIR%\DetroitBecomeHuman.exe"
rem  The shortcut is built in TEMP and then copied, never saved straight to the
rem  desktop. WScript.Shell's Save() writes nothing - and throws nothing - when
rem  the destination path contains characters outside the system ANSI codepage,
rem  which is exactly what a localised OneDrive desktop looks like. Copy-Item
rem  -LiteralPath handles Unicode properly.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$desk = [Environment]::GetFolderPath('Desktop');" ^
  "if (-not $desk -or -not (Test-Path -LiteralPath $desk)) { Write-Host '   [!] Desktop folder not found - shortcut skipped'; exit }" ^
  "$lnk = Join-Path $desk 'Detroit VR.lnk';" ^
  "$existed = Test-Path -LiteralPath $lnk;" ^
  "$tmp = Join-Path $env:TEMP 'DetroitVR.lnk';" ^
  "if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Force }" ^
  "$s = (New-Object -ComObject WScript.Shell).CreateShortcut($tmp);" ^
  "$s.TargetPath = $env:LNK_TARGET;" ^
  "$s.WorkingDirectory = $env:LNK_WORKDIR;" ^
  "if (Test-Path -LiteralPath $env:LNK_ICON) { $s.IconLocation = ($env:LNK_ICON + ',0') }" ^
  "$s.Description = 'Play Detroit: Become Human in VR';" ^
  "$s.Save();" ^
  "if (-not (Test-Path -LiteralPath $tmp)) { Write-Host '   [!] Could not build the shortcut - skipped'; exit }" ^
  "Copy-Item -LiteralPath $tmp -Destination $lnk -Force;" ^
  "Remove-Item -LiteralPath $tmp -Force;" ^
  "if (Test-Path -LiteralPath $lnk) { if ($existed) { Write-Host '   Desktop shortcut refreshed: Detroit VR' } else { Write-Host '   Desktop shortcut created: Detroit VR' } }" ^
  "else { Write-Host '   [!] Desktop shortcut could not be written - skipped' }"

:launch
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

if not "%LAUNCH_RESULT%"=="0" (
  echo(
  echo   The launcher reported a problem.
  echo(
  echo   There is no log unless you ask for one. To capture what happened,
  echo   create an empty file named  profiles\debug_log.flag  and run this
  echo   again; detroit_vr_debug.log then appears next to this file.
  echo   Delete the flag afterwards - the log grows large.
)
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
