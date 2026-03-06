@echo off
setlocal enabledelayedexpansion

set BASE=https://raw.githubusercontent.com/fabledruns/scripts/main
set SCRIPTS=bootstrap.ps1 filescan.ps1 ramhog.ps1 sysinfo.ps1

echo Downloading scripts...
for %%f in (%SCRIPTS%) do (
    curl -sSL "%BASE%/%%f" -o "%%f"
    echo   + %%f
)
echo.

:prompt
set /p CHOICE=Run Scripts? ~$ 

if /i "%CHOICE%"=="bootstrap" powershell -ExecutionPolicy Bypass -File bootstrap.ps1 & goto prompt
if /i "%CHOICE%"=="filescan" powershell -ExecutionPolicy Bypass -File filescan.ps1 & goto prompt
if /i "%CHOICE%"=="ramhog"   powershell -ExecutionPolicy Bypass -File ramhog.ps1   & goto prompt
if /i "%CHOICE%"=="sysinfo"  powershell -ExecutionPolicy Bypass -File sysinfo.ps1  & goto prompt
if /i "%CHOICE%"=="exit"     goto end
if /i "%CHOICE%"=="quit"     goto end

echo Unknown script. Available: bootstrap, filescan, ramhog, sysinfo, exit
goto prompt

:end
endlocal