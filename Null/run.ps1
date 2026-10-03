#requires -Version 7.0
<#
Null's author-edited workflow. Run from any directory with pwsh -File run.ps1.
Use -Chapter 2 to select a chapter explicitly. No Git operations are performed.
The author classifies each finding; no model validation is run after editing.
The script writes the validation artifact required by the revision command.
#>
[CmdletBinding()]
param(
    [ValidateRange(0, 999999)][int]$Chapter = 0,
    [string]$Model = 'qwen3.8:27b',
    [string]$WorkerProject = 'C:\Repos\SRD\StoryForge.Endless\src\StoryForge.Endless.Worker\StoryForge.Endless.Worker.csproj'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $false
$storyRoot = $PSScriptRoot
$chaptersRoot = Join-Path $storyRoot 'build/chapters'

function Read-Choice([string]$Prompt, [string[]]$Allowed) {
    while ($true) {
        $answer = (Read-Host $Prompt).Trim().ToUpperInvariant()
        if ($answer -in $Allowed) { return $answer }
        Write-Host ('Choose ' + ($Allowed -join ', ') + '.')
    }
}

function Invoke-Worker([string[]]$Command, [int[]]$AllowedExitCodes = @(0)) {
    & dotnet run -c Release --project $WorkerProject -- --repository-root $storyRoot @Command | Out-Host
    $workerExit = $LASTEXITCODE
    if ($workerExit -notin $AllowedExitCodes) {
        throw "StoryForge stopped with code $workerExit. Read the output above. No next chapter was started."
    }
}

function Get-NumberedFile([string]$Prefix, [string]$Extension) {
    Get-ChildItem -LiteralPath $chapterDir -File |
        Where-Object { $_.Name -match ('^' + [regex]::Escape($Prefix) + '(\d+)\.' + $Extension + '$') } |
        Sort-Object { [int]([regex]::Match($_.BaseName, '\d+$').Value) } -Descending |
        Select-Object -First 1
}

function Save-Draft([string]$Label) {
    $snapshot = Join-Path $backupDir ((Get-Date -Format 'yyyyMMdd-HHmmss-fffffff') + "-$Label.md")
    Copy-Item -LiteralPath $draftPath -Destination $snapshot
    return $snapshot
}

function Select-Draft {
    # WorkerPaths prefers the numerically latest revision unless draft.md is newer.
    $latest = Get-NumberedFile 'revision-' 'md'
    $selectedTime = [DateTime]::UtcNow
    if ($latest -and $latest.LastWriteTimeUtc -ge $selectedTime) {
        $selectedTime = $latest.LastWriteTimeUtc.AddSeconds(1)
    }
    [IO.File]::SetLastWriteTimeUtc($draftPath, $selectedTime)
}

function Assert-DraftUnchanged([string]$ExpectedHash) {
    if ((Get-FileHash -LiteralPath $draftPath).Hash -ne $ExpectedHash) {
        throw 'The draft changed while this step was running. Your edit is preserved. Restart the script to review the current text.'
    }
}

function Accept-SelectedDraft {
    Select-Draft
    $acceptedSnapshot = Save-Draft 'author-approved'
    if (Test-Path -LiteralPath $finalPath) { throw 'A final appeared during editing. Stopping to avoid accepting a different version.' }
    Write-Host "Author-approved source saved: $acceptedSnapshot"
    Invoke-Worker @('chapter', 'accept', "$Chapter")
    Write-Host "`nChapter $Chapter accepted. Run this script again when you want to work on the next chapter."
}

function Show-Difference([string]$Before, [string]$After) {
    if (Get-Command git -ErrorAction SilentlyContinue) {
        & git --no-pager diff --no-index --no-ext-diff --no-textconv -- $Before $After | Out-Host
        if ($LASTEXITCODE -gt 1) { throw 'Could not display the comparison.' }
    }
    else {
        Write-Host "Compare these files in your editor:`n  $Before`n  $After"
    }
}

try {
    if (!(Test-Path -LiteralPath $WorkerProject)) { throw "Worker project not found: $WorkerProject" }
    $env:STORYFORGE_OLLAMA_MODEL = $Model
    $env:STORYCAST_REPOSITORY_ROOT = 'C:\Repos\SRD\StoryCast'
    $env:STORYCAST_VOICE_LIBRARY = Join-Path $env:USERPROFILE 'Documents/StoryCast/voices'
    New-Item -ItemType Directory -Path $chaptersRoot -Force | Out-Null

    # Mirror the worker's next-chapter numbering, including unfinished drafts.
    $proseChapters = @(Get-ChildItem -LiteralPath $chaptersRoot -Directory |
        Where-Object { $_.Name -match '^chapter-\d+$' } |
        Where-Object {
            (Test-Path (Join-Path $_.FullName 'draft.md')) -or
            (Test-Path (Join-Path $_.FullName 'final.md')) -or
            @(Get-ChildItem -LiteralPath $_.FullName -File |
                Where-Object { $_.Name -like 'revision-*.md' -or $_.Name -like 'human-revision-*.md' }).Count -gt 0
        } | Sort-Object { [int]($_.Name.Substring(8)) })
    $nextChapter = 1
    if ($proseChapters.Count -gt 0) { $nextChapter = [int]($proseChapters[-1].Name.Substring(8)) + 1 }
    if ($Chapter -eq 0) {
        $unfinished = @($proseChapters | Where-Object {
            !(Test-Path (Join-Path $chaptersRoot ($_.Name + '.state-applied.json')))
        })
        if ($unfinished.Count -gt 0) { $Chapter = [int]($unfinished[0].Name.Substring(8)) }
        else { $Chapter = $nextChapter }
    }

    $chapterDir = Join-Path $chaptersRoot ('chapter-{0:000}' -f $Chapter)
    $draftPath = Join-Path $chapterDir 'draft.md'
    $finalPath = Join-Path $chapterDir 'final.md'
    Write-Host "`nNull - author-edited Chapter $Chapter ($Model)"

    if (Test-Path -LiteralPath $finalPath) {
        Write-Host "Already finalized: $finalPath"
        Write-Host 'Acceptance can retry pending arc/state work, but will NOT replace this final with an edited draft.'
        if ((Read-Choice '[R] Retry acceptance of existing final  [Q] Quit' @('R', 'Q')) -eq 'R') {
            Invoke-Worker @('chapter', 'accept', "$Chapter")
        }
        exit 0
    }

    New-Item -ItemType Directory -Path $chapterDir -Force | Out-Null
    $backupDir = Join-Path $chapterDir 'author-backups'
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    if (!(Test-Path -LiteralPath $draftPath)) {
        if ($Chapter -ne $nextChapter) { throw "The CLI can only generate Chapter $nextChapter. No files were regenerated." }
        Write-Host 'Generation also runs an initial review/validation and may attempt audio. Then you can edit and review, or accept as-is.'
        Write-Host 'The worker can replan after failed generation attempts. Existing chapter artifacts will be backed up first.'
        if ((Read-Choice '[G] Generate draft  [Q] Quit' @('G', 'Q')) -eq 'Q') { exit 0 }
        # Outside the chapter folder because the worker may archive that entire folder.
        $generationBackup = Join-Path $storyRoot ('build/author-backups/chapter-{0:000}-{1}' -f $Chapter, (Get-Date -Format 'yyyyMMdd-HHmmss-fffffff'))
        New-Item -ItemType Directory -Path $generationBackup -Force | Out-Null
        Get-ChildItem -LiteralPath $chapterDir -Force | Copy-Item -Destination $generationBackup -Recurse
        Write-Host "Pre-generation backup: $generationBackup"
        Invoke-Worker @('chapter', 'next') @(0, 2)
        if (!(Test-Path -LiteralPath $draftPath)) { throw 'Generation did not produce a draft.' }
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    }

    $entrySnapshot = Save-Draft 'on-entry'
    Write-Host "Draft backup: $entrySnapshot"
    $existingRevision = Get-NumberedFile 'revision-' 'md'
    if ($existingRevision) {
        Write-Host "An existing revision is available: $($existingRevision.FullName)"
        $sourceChoice = Read-Choice '[D] Work from draft.md  [V] View comparison  [R] Work from this revision  [Q] Quit' @('D', 'V', 'R', 'Q')
        while ($sourceChoice -eq 'V') {
            Show-Difference $draftPath $existingRevision.FullName
            $sourceChoice = Read-Choice '[D] Draft  [R] Revision  [Q] Quit' @('D', 'R', 'Q')
        }
        if ($sourceChoice -eq 'Q') { exit 0 }
        if ($sourceChoice -eq 'R') { Copy-Item -LiteralPath $existingRevision.FullName -Destination $draftPath }
    }
    Select-Draft

    while ($true) {
        Write-Host "`nSelected draft (edit and SAVE if needed):`n$draftPath"
        $editChoice = Read-Choice '[R] Saved; run review  [A] Accept as-is without another review  [Q] Quit' @('R', 'A', 'Q')
        if ($editChoice -eq 'Q') { exit 0 }
        if ($editChoice -eq 'A') {
            Accept-SelectedDraft
            exit 0
        }
        $reviewSource = Save-Draft 'before-review'
        Select-Draft
        $reviewHash = (Get-FileHash -LiteralPath $draftPath).Hash
        Invoke-Worker @('chapter', 'review', "$Chapter")
        Assert-DraftUnchanged $reviewHash
        $review = Get-NumberedFile 'review-' 'md'
        Write-Host "`nREVIEW (advisory): $($review.FullName)"
        $structuredReview = Get-Content -LiteralPath (Join-Path $chapterDir ($review.BaseName + '.json')) -Raw | ConvertFrom-Json
        Write-Host $structuredReview.OverallAssessment
        $findings = @($structuredReview.Findings)
        $decisions = [Collections.Generic.List[object]]::new()
        $approvedCorrections = [Collections.Generic.List[string]]::new()
        $blockingCount = 0
        $optionalCount = 0
        $rejectedCount = 0
        for ($index = 0; $index -lt $findings.Count; $index++) {
            $finding = $findings[$index]
            Write-Host "`nFinding $($index + 1) of $($findings.Count): $($finding.Category)"
            Write-Host $finding.Finding
            Write-Host "Evidence: $($finding.Evidence)"
            $classification = Read-Choice '[0] Rejected (Dismissed)  [1] Optional (NonBlocking)  [2] Blocking  [Q] Quit' @('0', '1', '2', 'Q')
            if ($classification -eq 'Q') { exit 0 }
            $includeInRevision = $false
            switch ($classification) {
                '2' { $disposition = 2; $label = 'Blocking'; $blockingCount++; $includeInRevision = $true }
                '1' {
                    $disposition = 1; $label = 'Optional'; $optionalCount++
                    $includeInRevision = (Read-Choice 'Include this optional finding in cleanup? [Y] Yes  [N] No' @('Y', 'N')) -eq 'Y'
                }
                '0' { $disposition = 0; $label = 'Rejected'; $rejectedCount++ }
            }
            $decisions.Add([ordered]@{
                FindingIndex = $index
                Disposition = $disposition
                Evidence = $finding.Evidence
                Reason = "Human author classified this finding as $label. Include in requested revision: $includeInRevision."
            })
            if ($includeInRevision) {
                $approvedCorrections.Add("Finding $($index + 1) ($label): $($finding.Finding)`nEvidence: $($finding.Evidence)")
            }
        }
        Assert-DraftUnchanged $reviewHash
        $validation = Join-Path $chapterDir ($review.BaseName + '.validation.json')
        # Numeric values match ReviewFindingDisposition: Dismissed=0, NonBlocking=1, Blocking=2.
        [ordered]@{
            ValidationProtocolVersion = 2
            HasTechnicalFailures = $false
            Validations = @($decisions.ToArray())
            Model = 'manual-author-review'
            Duration = '00:00:00'
            HasBlockingFindings = ($blockingCount -gt 0)
            SourceSha256 = $reviewHash
        } | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $validation -Encoding utf8
        Write-Host "`nYour decisions: $blockingCount blocking, $optionalCount optional, $rejectedCount rejected."
        Write-Host "Saved: $validation"

        if ($blockingCount -gt 0) {
            $action = Read-Choice '[C] Request cleanup  [E] Edit and review again  [Q] Quit' @('C', 'E', 'Q')
        }
        else {
            $action = Read-Choice '[C] Request cleanup  [A] Accept my draft  [E] Edit and review again  [Q] Quit' @('C', 'A', 'E', 'Q')
        }
        if ($action -eq 'Q') { exit 0 }
        if ($action -eq 'E') { continue }
        Assert-DraftUnchanged $reviewHash

        if ($action -eq 'C') {
            Write-Host 'Enter the corrections you approve, one line at a time. Enter a single period to finish.'
            Write-Host 'With no extra instructions, request spelling, grammar and punctuation corrections only.'
            $instructionLines = [Collections.Generic.List[string]]::new()
            while ($true) {
                $line = Read-Host 'Correction'
                if ($line.Trim() -eq '.') { break }
                if (![string]::IsNullOrWhiteSpace($line)) { $instructionLines.Add($line) }
            }
            $instruction = 'Copyedit the author-selected draft. Correct spelling, grammar, and punctuation. Preserve the author''s voice, events, characterization, viewpoint, and intentional mysteries. Do not expand to meet a word target. Do not apply other review findings unless explicitly approved below. Preserve unaffected wording.'
            if ($approvedCorrections.Count -gt 0) { $instruction += "`nAuthor-approved review findings:`n" + ($approvedCorrections -join "`n`n") }
            if ($instructionLines.Count -gt 0) { $instruction += "`nAdditional author instructions:`n" + ($instructionLines -join "`n") }
            Assert-DraftUnchanged $reviewHash
            Select-Draft
            Invoke-Worker @('chapter', 'revise', "$Chapter", $instruction)
            Assert-DraftUnchanged $reviewHash
            $proposal = Get-NumberedFile 'revision-' 'md'
            if (!$proposal) { throw 'No revision was produced.' }
            # Keep the author draft selected until a proposal is explicitly chosen.
            Select-Draft
            Write-Host "`nProposed revision: $($proposal.FullName)"
            $proposalHash = (Get-FileHash -LiteralPath $proposal.FullName).Hash
            Show-Difference $reviewSource $proposal.FullName
            if ($blockingCount -gt 0) {
                Write-Host 'Check that the revision resolves your blocking findings before accepting it.'
                $decision = Read-Choice '[A] Accept revision  [P] Edit proposed revision  [E] Edit original draft  [Q] Quit' @('A', 'P', 'E', 'Q')
            }
            else {
                $decision = Read-Choice '[A] Accept revision  [K] Keep and accept my draft  [P] Edit proposed revision  [E] Edit original draft  [Q] Quit' @('A', 'K', 'P', 'E', 'Q')
            }
            if ($decision -eq 'Q') { exit 0 }
            if ($decision -eq 'E') { continue }
            Assert-DraftUnchanged $reviewHash
            if ($decision -in @('A', 'P')) {
                if ((Get-FileHash -LiteralPath $proposal.FullName).Hash -ne $proposalHash) {
                    throw 'The proposed revision changed after comparison. Restart to inspect the updated version.'
                }
                $null = Save-Draft 'before-selected-revision'
                Copy-Item -LiteralPath $proposal.FullName -Destination $draftPath
                if ($decision -eq 'P') { Select-Draft; continue }
            }
        }

        Accept-SelectedDraft
        exit 0
    }
}
catch {
    Write-Host "`n$($_.Exception.Message)" -ForegroundColor Red
    Write-Host 'Stopped. Existing prose and backups remain available. No automatic continuation.'
    exit 1
}
