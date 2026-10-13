@echo off
setlocal
title AsTheWorldRolls
set "STORYCAST_REPOSITORY_ROOT=C:\Repos\SRD\StoryCast"
set "STORYCAST_VOICE_LIBRARY=C:\Users\User\Documents\StoryCast\samples"
set "STORY_ROOT=%~dp0"
set "STORY_ROOT=%STORY_ROOT:~0,-1%"
if exist "%STORY_ROOT%\.storyforge\episode-complete.json" (
    echo As the World Rolls is complete at Chapter 18.
    echo The next independent episode should use a separate story workspace.
    pause
    exit /b 0
)
dotnet run -c Release --project "C:\Repos\SRD\StoryForge.Endless\src\StoryForge.Endless.Worker\StoryForge.Endless.Worker.csproj" -- --repository-root "%STORY_ROOT%" chapter run
set "RUN_EXIT=%ERRORLEVEL%"
echo.
if not "%RUN_EXIT%"=="0" echo Chapter run stopped with code %RUN_EXIT%.
pause
exit /b %RUN_EXIT%
