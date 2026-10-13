$ErrorActionPreference = 'Stop'
$storyRoot = 'C:\repos\SRD\StoryForge.Publish\AsTheWorldRolls'
$recoveryRoot = Join-Path $storyRoot '.storyforge\editorial-recovery\20261012-115913'
$contextRoot = Join-Path $recoveryRoot 'rebuilt\context\generation'
New-Item -ItemType Directory -Path $contextRoot -Force | Out-Null
$state = Get-Content -Raw -LiteralPath (Join-Path $recoveryRoot 'context\generation\STORY-ARCS.json') | ConvertFrom-Json
function New-Target($sequence, $chapter, $objective, $change, $choice, $discovery, $closing, $later, $evidence) {
    [pscustomobject][ordered]@{
        Sequence = $sequence; ChapterNumber = $chapter
        DramaticQuestion = "Can the companions $objective"
        Objective = $objective; IntendedChange = $change
        CharacterDevelopmentTarget = 'Elias accepts help and distributes responsibility; Kaelen retains agency; competence does not require self-sacrifice.'
        RelationshipTargets = @([pscustomobject]@{
            CharacterAId = 'Elias Thorne'; CharacterBId = 'Kaelen'
            StartingDynamic = 'Companions under strain who trust each other but disagree about the cost of responsibility.'
            IntendedChange = $change
            Tension = 'Duty to the group must not become permission to exhaust or control one person.'
            PowerDynamic = 'Elias coordinates; Kaelen chooses his participation and states his own limits.'
            Subtext = 'Accepting help and accepting an ending are forms of trust.'
            PreservedBoundary = 'Professional, non-romantic companionship; preserve all established relationships.'
            ReservedLaterWork = @($later)
        })
        WorldbuildingTargets = @('The Gate of Silence shrine and the distant temple barrier are separate places linked by a channel; do not relocate the barrier.', 'Ordinary injuries, travel, supplies, and institutional responsibility remain material constraints.')
        Complications = @('Fatigue, injuries, uncertainty, and incomplete information require credible decisions rather than an invented magical solution.')
        RequiredChoice = $choice
        Consequences = @($change)
        DiscoveryTarget = $discovery
        SetupElements = @('Use only facts established in the retained canon or concretely established in this chapter.')
        PayoffElements = @('Pay off the companions'' return promise and their trust through observed consequences.')
        ThematicPressure = 'Competence includes knowing when to stop and allowing others to share responsibility.'
        ResolutionContributions = @($closing)
        ReservedLaterWork = @($later)
        ClosingState = $closing
        IsCompleted = ($null -ne $evidence)
        CompletedInChapter = $(if ($null -ne $evidence) { $chapter } else { $null })
        CompletionEvidence = [string[]]@($(if ($null -ne $evidence) { $evidence }))
    }
}
$blight = $state.Arcs | Where-Object Id -eq 'short-final-blight-counterattack'
# Chapter 14's target and completion receipt remain exactly as archived.
$target15 = New-Target 2 15 'recover control after the quartz fails during the second phase.' 'The companions replace a dangerous, person-dependent restriction with a tested arrangement of broken quartz; Kaelen is no longer forced to pull.' 'Stop the stronger pull rather than spend Kaelen as a replaceable component.' 'Fragments can answer the established note at tested angles, but the reservoir is not yet empty.' 'The feed remains limited and stable; the hammer is withdrawn and all five remain alive.' @('Empty the local reservoir and close the channel in Chapter 16; do not claim success before testing independence.') 'But Maren and Torin no longer had to hold the gap with their hands, and Kaelen was still himself.'
$target16 = New-Target 3 16 'finish the local Blight counterattack and withdraw safely.' 'The temple consumes the remaining local feed; the channel is closed and holds without human maintenance.' 'Reject a stronger pull and use the observed channel behavior to finish without sacrificing Kaelen.' 'The creatures in the ditch lose cohesion when the diverted feed reaches the temple; the reservoir pressure ceases.' 'The replacement key is left closed, the party tests it from outside range, and all five start the return journey.' @() 'But the reservoir they had opened no longer pressed against the shrine. The barrier had consumed the released corruption. The creatures in the ditch had collapsed when the stream was drawn away from them, and nothing had risen to replace them.'
$blight.ChapterTargets = @($blight.ChapterTargets | Where-Object Sequence -eq 1) + @($target15, $target16)
$blight.Objective = 'Finish the operation begun in immutable Chapter 14: recover from the failed stronger pull, feed the local reservoir into the established consuming barrier, and close the channel without sacrificing a companion.'
$blight.ResolutionCriteria = 'The local reservoir pressure has ceased; the channel remains closed without a person maintaining it; the temple barrier is steady; all five can leave. Do not claim the entire world is cleansed or the forest mystery explained.'
$blight.CurrentPhase = 'Completed in rebuilt Chapter 16: the local feed was consumed, the channel closed and tested, and all five withdrew.'
$blight.NextMilestone = ''
$prelude = $state.Arcs | Where-Object Id -eq 'medium-blight-prelude'
$prelude.CurrentPhase = 'The local operation concludes in rebuilt Chapter 16. Independent observation and the transfer of responsibility follow in Chapters 17-18.'
$post = $state.Arcs | Where-Object Id -eq 'short-tavern-notice'
$post.PrimaryTrope = 'The return and the earned rest'
$post.Objective = 'Bring the companions home, document the completed operation honestly, transfer the watch to the watchfort, and let the first episode end at Chapter 18. Chapter 19 is outside this closed episode.'
$post.ResolutionCriteria = 'The returning party gives a usable report; the watchfort takes responsibility; injuries are treated and the companions reach an ordinary, stable stopping point. Any third-target development belongs to a separate future episode, not a missing payoff here.'
$post.CurrentPhase = 'Rebuilt Chapter 18 ends the first episode with independent observation, a completed report, paid rooms, and all five at the table.'
$post.NextMilestone = 'No more chapters in this episode. If the author later starts another episode, create its independent premise and workspace instead of restarting the resolved Blight operation.'
$post.ChapterTargets = @(
    (New-Target 1 17 'return to the watchfort and transfer responsibility for the closed channel.' 'The companions leave the shrine, arrive together, receive treatment, and share the operation and observation instructions.' 'Accept help and allow the watchfort to carry the next watch instead of returning exhausted.' 'The operation can hold without the party remaining at the shrine.' 'All five are resting at the watchfort; observation instructions have reached an independent watch.' @('Independent verification, final account, and quiet episode closure belong to Chapter 18.') 'Within a few minutes, people who had not stood at the shrine were gathering blankets and water for the ridge watch.'),
    (New-Target 2 18 'verify the outcome and close this episode at a stable stopping point.' 'Independent watches report no renewed feed; the party completes an honest account and chooses recovery rather than another obligation.' 'Stop seeking certainty by returning to danger; accept a bounded victory and ordinary rest.' 'Independent reports corroborate the closure; uncertainty about the forest keeper is an intellectual unknown, not an urgent cliffhanger.' 'The report and map copies are entrusted to the watchfort; all five have a meal and rooms at the Gilded Tankard; no caravan contract, summons, new threat, or departure launches another adventure.' @('Chapter 19 and later plans are future-series reserves outside this closed episode. They do not prevent the ending at 18.') 'For tonight, all five had a place at the table.'),
    (New-Target 3 19 'begin a separate self-contained adventure only if explicitly requested in a new episode.' 'A future episode starts from the recurring cast and stable world, not from an unresolved duty in this completed book.' 'Choose a fresh independent premise rather than replaying or reopening the resolved local Blight operation.' 'Any future problem must be newly established in that episode, not revealed as a last-minute twist in Chapter 18.' 'Prospective future-series work only. This target has not occurred and is not required to complete Episode One.' @() $null)
)
$medium = $state.Arcs | Where-Object Id -eq 'medium-first-contract'
$medium.PrimaryTrope = 'Recovery and independent episodes'
$medium.Objective = 'Close the current adventure through the return and debrief in Chapters 17-18. Reserve any later self-contained adventures for future episodes with separately established premises; no caravan or raider obligation exists in this book.'
$medium.ResolutionCriteria = 'The current episode has a verified, human-scale ending at 18. Completion of this structural Medium reserve would require later independent episodes and is not claimed now.'
$medium.CurrentPhase = 'The first episode is complete at Chapter 18; later structural slots are unused series reserves.'
$medium.NextMilestone = 'Only author-authorized future episodes may use the remaining series reserve.'
$long = $state.Arcs | Where-Object Id -eq 'long-frontier-road'
$long.Objective = 'Provide a series framework for the recurring companions, starting with a completed local Blight adventure and recovery. Later village or road adventures belong to separate episodes and are not obligations of Episode One.'
$long.ResolutionCriteria = 'The first local adventure is finished and documented. The longer series framework is not resolved early and requires separately authorized future episodes.'
$long.CurrentPhase = 'Local Blight feed closed in Chapter 16; return and independent observation complete by Chapter 18.'
$long.NextMilestone = 'Leave this episode closed; future independent adventures require a new author-approved premise.'
$epic = $state.Arcs | Where-Object Id -eq 'epic-company-of-the-open-road'
$epic.Objective = 'Retain the recurring cast and world across independent, self-contained adventures. Episode One ends at Chapter 18; fame, guild campaigns, tournaments, dragons, and further escalation are not required to finish it.'
$epic.ResolutionCriteria = 'The series framework spans possible future independent episodes. Do not force the current book to complete its unused hierarchy or falsely mark those future adventures as accomplished.'
$epic.CurrentPhase = 'Episode One closed after the local Blight operation, return, verification, and rest.'
$epic.NextMilestone = 'No continuation without an author-approved new episode.'
foreach ($arc in $state.Arcs | Where-Object {$_.Status -eq 'Planned' -and $_.StartChapter -gt 18}) {
    $arc.Objective = 'Future-series reserve outside the completed first episode. Archived possibility, not a current obligation: ' + $arc.Objective
    $arc.CurrentPhase = 'Unused prospective series reserve. No events here are established canon or obligations of Episode One.'
}
$state | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath (Join-Path $contextRoot 'STORY-ARCS.json') -Encoding utf8

$threads = Get-Content -Raw -LiteralPath (Join-Path $recoveryRoot 'context\generation\NARRATIVE-THREADS.json') | ConvertFrom-Json
foreach ($thread in $threads.Threads) {
    $thread.CompletedDevelopments = @($thread.CompletedDevelopments | Where-Object ChapterNumber -le 14)
    $thread.LastAdvancedChapter = 18
    $thread.Status = $(if ($thread.Id -eq 'mystery-003') { 1 } else { 2 })
    $thread.CurrentQuestion = $(if ($thread.Id -eq 'mystery-003') { 'What is the full nature of the forest keeper and its reference to the key? This background uncertainty does not prevent closure of the completed local adventure.' } else { $null })
    $thread.Summary = $(if ($thread.Id -eq 'mystery-003') { 'The local operation is complete and independently corroborated. The companions explicitly acknowledge that the forest keeper and the full meaning of its key remain incompletely understood. This is dormant background knowledge, not an immediate peril or obligation to continue the episode.' } else { 'The local feed at the Gate of Silence was consumed and the channel closed in Chapter 16; the party returned and transferred responsibility in 17; independent watches corroborated the closure in 18. The episode ends with all five recovering safely.' })
    $thread.RequiredContinuity = @('The shrine and temple barrier are separate sites.', 'The original quartz is broken; three working fragments remain in the closed groove.', 'Kaelen is no longer maintaining the channel and is free to leave his gauntlet unworn.', 'The watchfort has observation instructions; the city is not declared universally safe.', 'No Temple Springs cargo, merchant contract, lunar-cycle theory, or raid obligation belongs to the rebuilt continuation.')
    $thread.CompletedDevelopments += @(
        [pscustomobject]@{ChapterNumber=15;Development='The stronger pull breaks the quartz; a tested fragment arrangement limits the feed without making Maren and Torin hold the hammer indefinitely or requiring Kaelen to pull.'},
        [pscustomobject]@{ChapterNumber=16;Development='The flow is redirected to the temple, the local reservoir empties, and the closed channel holds after the party moves outside range.'},
        [pscustomobject]@{ChapterNumber=17;Development='All five return to the watchfort, receive treatment, and transfer usable observation instructions to an independent watch.'},
        [pscustomobject]@{ChapterNumber=18;Development='Independent reports corroborate closure; the party documents its limits honestly and rests at the Gilded Tankard without accepting another quest.'}
    )
}
$threads | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath (Join-Path $contextRoot 'NARRATIVE-THREADS.json') -Encoding utf8

$canon = Get-Content -Raw -LiteralPath (Join-Path $recoveryRoot 'context\generation\CANON.md')
$canon = ($canon -split [regex]::Escape('- The barrier is currently being physically blocked by a wooden hammer handle'))[0].TrimEnd()
$canon += @'


## Rebuilt continuation: Chapters 15-18

- Chapters 1-14, ending with The Gate of Silence, are immutable. The prose is authoritative over summaries and earlier projections.
- The quartz breaks during the stronger pull in Chapter 15. The party tests three fragments in the existing groove and uses stone wedges and a leather sling to hold their angles; this is an observed local repair, not a universal new magic system.
- The consuming barrier remains at the temple across the valley. It does not move to the shrine or expand around the party.
- In Chapter 16, a creature in the ditch briefly diverts the feed. Restoring the fragment angle redirects the feed to the temple; the creature loses cohesion.
- The local reservoir pressure ceases, the note is withdrawn without a surge, and the narrowed groove remains closed after the party leaves. This does not establish that all Blight everywhere is destroyed or the enormous silhouette is dead.
- All five return to the watchfort in 17. Injuries receive ordinary treatment; the report and diagrams transfer responsibility to independent observers.
- Independent watches corroborate the steady barrier and absent renewed feed in 18. The city remains restricted pending inspection.
- At the ending, the companions have food and rooms at the Gilded Tankard outside the watchfort. Maren has a replacement hammer haft; Elias keeps the bronze map after copies are checked; Kaelen may leave his gauntlet unworn; Elara retains the chisel and notes. Working quartz shards remain at the shrine.
- The forest keeper's nature remains uncertain, but it is not an unresolved rescue, immediate threat, or cliffhanger. The characters explicitly distinguish unfinished knowledge from unfinished work.
- The superseded Silas Vane, Temple Springs cargo, alchemist contract, sulfur paste repellent, lunar-cycle theory, and caravan departure are not part of the rebuilt Chapters 15-18 and must not be carried forward as canon.
- Episode One is complete at 18. No next chapter, successor adventure, or new episode is authorized by an unused arc slot.
'@
Set-Content -LiteralPath (Join-Path $contextRoot 'CANON.md') -Value $canon -Encoding utf8
