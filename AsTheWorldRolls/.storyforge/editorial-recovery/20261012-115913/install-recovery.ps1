$ErrorActionPreference = 'Stop'
$storyRoot = [IO.Path]::GetFullPath('C:\repos\SRD\StoryForge.Publish\AsTheWorldRolls')
$recoveryRoot = Join-Path $storyRoot '.storyforge\editorial-recovery\20261012-115913'
$rebuiltRoot = Join-Path $recoveryRoot 'rebuilt'
$hashes = Get-Content -Raw -LiteralPath (Join-Path $recoveryRoot 'immutable-canon-hashes.json') | ConvertFrom-Json
foreach ($entry in $hashes) {
    if ((Get-FileHash -LiteralPath $entry.Path).Hash -ne $entry.Hash) { throw "Protected canon changed: $($entry.Path)" }
}
foreach ($number in 15..18) {
    $name = 'chapter-{0:000}.md' -f $number
    $path = Join-Path $rebuiltRoot $name
    if (!(Test-Path -LiteralPath $path)) { throw "Missing rebuilt chapter: $name" }
    $newText = Get-Content -Raw -LiteralPath $path
    $oldText = ((Get-Content -Raw -LiteralPath (Join-Path $recoveryRoot ('publication\chapters\' + $name))) -split '\r?\n---\r?\n')[0]
    if ([regex]::Matches($newText, '\S+').Count -lt [regex]::Matches($oldText, '\S+').Count * 0.95) { throw "Rebuilt chapter materially shortened: $name" }
}

$archived = [Collections.Generic.List[string]]::new()
function Archive-LaterArtifacts($relativeRoot, $isDirectory) {
    $sourceRoot = Join-Path $storyRoot $relativeRoot
    if (!(Test-Path -LiteralPath $sourceRoot)) { return }
    foreach ($item in Get-ChildItem -LiteralPath $sourceRoot -Force) {
        if ($item.Name -notmatch '^chapter-(\d+)(?:\.|$)' -or [int]$Matches[1] -le 14 -or $item.PSIsContainer -ne $isDirectory) { continue }
        $source = [IO.Path]::GetFullPath($item.FullName)
        $destination = [IO.Path]::GetFullPath((Join-Path $recoveryRoot ('superseded\' + $relativeRoot + '\' + $item.Name)))
        if (!$source.StartsWith($sourceRoot + '\', [StringComparison]::OrdinalIgnoreCase) -or !$destination.StartsWith($recoveryRoot + '\', [StringComparison]::OrdinalIgnoreCase)) { throw 'Archive path escaped its intended roots.' }
        if (Test-Path -LiteralPath $destination) { throw "Archive already exists: $destination" }
        New-Item -ItemType Directory -Path (Split-Path $destination) -Force | Out-Null
        Move-Item -LiteralPath $source -Destination $destination
        $archived.Add($source)
    }
}
Archive-LaterArtifacts 'build\chapters' $true
Archive-LaterArtifacts 'build\chapters\rejected' $true
Archive-LaterArtifacts 'build\chapters\diagnostics' $true
Archive-LaterArtifacts 'build\chapters\diagnostics\history' $true
Archive-LaterArtifacts 'production\scripts' $false
Archive-LaterArtifacts 'output\final' $false

foreach ($number in 15..18) {
    $name = 'chapter-{0:000}.md' -f $number
    $source = Join-Path $rebuiltRoot $name
    Copy-Item -LiteralPath $source -Destination (Join-Path $storyRoot ('publication\chapters\' + $name))
    Copy-Item -LiteralPath $source -Destination (Join-Path $storyRoot ('production\chapters\' + $name))
    $buildRoot = Join-Path $storyRoot ('build\chapters\chapter-{0:000}' -f $number)
    New-Item -ItemType Directory -Path $buildRoot -Force | Out-Null
    Copy-Item -LiteralPath $source -Destination (Join-Path $buildRoot 'final.md')
    $title = (Get-Content -LiteralPath $source -TotalCount 1) -replace '^# Chapter \d+: ', ''
    Set-Content -LiteralPath (Join-Path $buildRoot 'title.txt') -Value $title -Encoding utf8
    [ordered]@{
        Source = 'Author-authorized editorial rebuild'; CanonCutoff = 14; EpisodeEnding = 18
        ManuscriptHash = (Get-FileHash -LiteralPath $source).Hash
        SupersededArtifacts = 'Archived; not evidence for this replacement manuscript.'
        ModelValidation = 'No live model review claimed. Structural state and source receipts checked independently.'
    } | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $buildRoot 'editorial-rebuild.json') -Encoding utf8
}

foreach ($file in Get-ChildItem -LiteralPath (Join-Path $rebuiltRoot 'context\generation') -File) {
    Copy-Item -LiteralPath $file.FullName -Destination (Join-Path $storyRoot ('context\generation\' + $file.Name))
}

$chapterHashes = Get-ChildItem -LiteralPath (Join-Path $storyRoot 'publication\chapters') -Filter 'chapter-*.md' | Sort-Object Name | Get-FileHash
$marker = [ordered]@{
    SchemaVersion = 1; Title = 'As the World Rolls'; Status = 'Complete'; FinalChapter = 18
    ImmutableCanonThrough = 14; ImmutableCanonTitle = 'The Gate of Silence'
    EditorialBackup = '.storyforge/editorial-recovery/20261012-115913'
    Notes = 'Chapters 15-18 were rebuilt with author authorization. Future series arcs are unused reserves. Start the next independent episode in a separate workspace. Direct Worker CLI calls do not consult this launcher marker.'
    Chapters = @($chapterHashes | Select-Object Path,Hash)
}
$marker | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $storyRoot '.storyforge\episode-complete.json') -Encoding utf8

Copy-Item -LiteralPath (Join-Path $storyRoot 'run.bat') -Destination (Join-Path $recoveryRoot 'run.bat')
$launcher = Get-Content -Raw -LiteralPath (Join-Path $storyRoot 'run.bat')
$guard = @'
if exist "%STORY_ROOT%\.storyforge\episode-complete.json" (
    echo As the World Rolls is complete at Chapter 18.
    echo The next independent episode should use a separate story workspace.
    pause
    exit /b 0
)
'@
$launcher = $launcher.Replace('dotnet run -c Release', $guard + "`r`n" + 'dotnet run -c Release')
Set-Content -LiteralPath (Join-Path $storyRoot 'run.bat') -Value $launcher -NoNewline -Encoding ascii

$archived | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $recoveryRoot 'archived-paths.json') -Encoding utf8
foreach ($entry in $hashes) {
    if ((Get-FileHash -LiteralPath $entry.Path).Hash -ne $entry.Hash) { throw "Protected canon changed: $($entry.Path)" }
}
'Rebuilt Chapters 15-18 installed; all 14 protected canon hashes unchanged.'
