@echo off
setlocal
title Crucible of Ages - draft review and audio
set "STORYCAST_REPOSITORY_ROOT=C:\Repos\SRD\StoryCast"
set "STORYCAST_VOICE_LIBRARY=C:\Users\David\Documents\StoryCast\voices"
set "STORY_ROOT=%~dp0"
set "STORY_ROOT=%STORY_ROOT:~0,-1%"
dotnet run -c Release --project "C:\Repos\SRD\StoryForge.Endless\src\StoryForge.Endless.Worker\StoryForge.Endless.Worker.csproj" -- --repository-root "%STORY_ROOT%" chapter run
set "RUN_EXIT=%ERRORLEVEL%"
echo.
if not "%RUN_EXIT%"=="0" echo Chapter run stopped with code %RUN_EXIT%.
pause
exit /b %RUN_EXIT%
