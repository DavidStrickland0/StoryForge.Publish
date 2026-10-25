$ErrorActionPreference = 'Stop'
$env:STORYFORGE_OLLAMA_MODEL_GENERATION = 'qwen3.8:27b'
$env:STORYFORGE_OLLAMA_MODEL_VALIDATION = 'qwen3.5:9b'
$runDirectory = Join-Path $PSScriptRoot ('chapter-004-rerun-' + (Get-Date -Format 'yyyyMMdd-HHmmss'))
New-Item -ItemType Directory -Path $runDirectory | Out-Null
Set-Content -LiteralPath (Join-Path $PSScriptRoot 'chapter-004-rerun-latest.txt') -Value $runDirectory
$logPath = Join-Path $runDirectory 'run.log'
try {
    Set-Location -LiteralPath 'C:\repos\SRD\StoryForge.Endless'
    & dotnet run --no-restore --project 'C:\repos\SRD\StoryForge.Endless\src\StoryForge.Endless.Worker' -- --repository-root 'C:\repos\SRD\StoryForge.Publish\ATWR.Episode2' chapter generate 4 *> $logPath
    $runExitCode = $LASTEXITCODE
    Set-Content -LiteralPath (Join-Path $runDirectory 'exit-code.txt') -Value $runExitCode
    exit $runExitCode
}
catch {
    $_ | Out-String | Add-Content -LiteralPath $logPath
    Set-Content -LiteralPath (Join-Path $runDirectory 'exit-code.txt') -Value 1
    exit 1
}
