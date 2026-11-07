@echo off
setlocal
title Crucible of Ages - Beat Editor
set "STORY_ROOT=%~dp0"
set "STORY_ROOT=%STORY_ROOT:~0,-1%"
set "STORYFORGE_PROJECT=%~dp0..\..\StoryForge.Endless\src\StoryForge.Endless.Worker\StoryForge.Endless.Worker.csproj"
if not exist "%STORYFORGE_PROJECT%" (
    echo Clone StoryForge.Endless beside StoryForge.Publish before starting the editor.
    pause
    exit /b 1
)
dotnet run -c Release --project "%STORYFORGE_PROJECT%" -- --repository-root "%STORY_ROOT%" editor
set "RUN_EXIT=%ERRORLEVEL%"
if not "%RUN_EXIT%"=="0" echo Beat editor stopped with code %RUN_EXIT%.
pause
exit /b %RUN_EXIT%
