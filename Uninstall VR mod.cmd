@echo off
setlocal EnableExtensions
cd /d "%~dp0"

rem ===========================================================================
rem  UNINSTALLER
rem
rem  Puts the game back exactly as it was: restores GraphicOptions.JSON from the
rem  backup taken before the first launch, removes the read-only lock, and then
rem  deletes this whole DETROIT_VR_MOD folder.
rem
rem  Nothing outside this folder is touched except GraphicOptions.JSON, which is
rem  restored rather than deleted. Your saves are never involved.
rem ===========================================================================

set "GAME_DIR=%~dp0.."
set "CFG=%GAME_DIR%\GraphicOptions.JSON"

echo(
echo  ================================================================
echo    DETROIT VR MOD  -  UNINSTALL
echo  ================================================================
echo(
echo   This will:
echo     1. unlock GraphicOptions.JSON and restore your original settings
echo        ^(including the frame rate cap the mod changed^)
echo     2. remove the steam_appid.txt the launcher wrote, if it wrote one
echo     3. remove any "Detroit VR" desktop shortcut an older version left
echo     4. delete this entire folder:
echo        %~dp0
echo(
echo   Your game, your saves and every other file are left alone.
echo   Detroit will then run normally on your monitor again.
echo(

set "ANSWER="
set /p "ANSWER=  Type  YES  and press Enter to uninstall (anything else cancels): "
if /i not "%ANSWER%"=="YES" (
  echo(
  echo   Cancelled. Nothing was changed.
  echo(
  pause
  exit /b 0
)

echo(

rem --- 1. settings ------------------------------------------------------------
if exist "%CFG%" (
  attrib -r "%CFG%" >nul 2>&1
  echo   Removed the read-only lock from GraphicOptions.JSON
)

if exist "%CFG%.vrmod-backup" (
  copy /y "%CFG%.vrmod-backup" "%CFG%" >nul
  del /q "%CFG%.vrmod-backup" >nul 2>&1
  echo   Restored your original GraphicOptions.JSON ^(frame cap back to normal^)
) else (
  echo   [!] No backup found. The frame rate cap may still be set to unlimited -
  echo       change it in the game's VIDEO options if you want the default back.
)

rem --- 2. steam_appid.txt ------------------------------------------------------
rem  Only the one the launcher wrote, which is why it leaves a marker: a
rem  steam_appid.txt that was already there belongs to something else and stays.
if not exist "%~dp0steam_appid.created" goto :appid_kept
if exist "%GAME_DIR%\steam_appid.txt" del /q "%GAME_DIR%\steam_appid.txt" >nul 2>&1
del /q "%~dp0steam_appid.created" >nul 2>&1
echo   Removed the steam_appid.txt the mod created
:appid_kept

rem --- 3. desktop shortcut ----------------------------------------------------
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$desk = [Environment]::GetFolderPath('Desktop');" ^
  "if (-not $desk) { exit }" ^
  "$lnk = Join-Path $desk 'Detroit VR.lnk';" ^
  "if (Test-Path -LiteralPath $lnk) { Remove-Item -LiteralPath $lnk -Force; Write-Host '   Removed the Detroit VR desktop shortcut' }" ^
  "else { Write-Host '   No Detroit VR desktop shortcut to remove' }"

rem --- 4. this folder ---------------------------------------------------------
rem  A running .cmd cannot delete the folder it is executing from, so the removal
rem  is handed to a detached shell that waits for this one to exit first.
echo   Removing the mod folder...
echo(
echo   Done. Detroit will start normally from Steam or its own shortcut.
echo(
pause

start "" /min cmd /c "ping -n 3 127.0.0.1 >nul & rd /s /q ""%~dp0."" "
endlocal
exit /b 0
