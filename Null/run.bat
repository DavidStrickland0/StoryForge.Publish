@echo off
setlocal
title Null - author edit and review
pwsh -NoProfile -File "%~dp0run.ps1" %*
set "RUN_EXIT=%ERRORLEVEL%"
echo.
if not "%RUN_EXIT%"=="0" echo Chapter run stopped with code %RUN_EXIT%.
pause
exit /b %RUN_EXIT%
