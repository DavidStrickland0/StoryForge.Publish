$ErrorActionPreference = 'Stop'
$storyRoot = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../..'))
$arcPath = Join-Path $storyRoot 'context/generation/STORY-ARCS.json'
$backupPath = Join-Path $PSScriptRoot 'STORY-ARCS.before.json'
if (Test-Path -LiteralPath $backupPath) { throw 'Repair already has a backup; do not replay over later story progress.' }
Copy-Item -LiteralPath $arcPath -Destination $backupPath
$state = Get-Content -Raw -LiteralPath $arcPath | ConvertFrom-Json
$beforeHashes = @{}
1..4 | ForEach-Object { $p = Join-Path $storyRoot ('build/chapters/chapter-{0:000}/final.md' -f $_); $beforeHashes[[string]$_] = (Get-FileHash -LiteralPath $p).Hash }
$prefix = 'epic-001-081-long-1-medium-1'
$current = @($state.Arcs | Where-Object Id -eq "$prefix-short-2")[0]
$next = @($state.Arcs | Where-Object Id -eq "$prefix-short-3")[0]
$phase = 'Caelen died protecting a mother, experienced the void in Chapter 2, and was resurrected, assessed, collared and transported by slavers in Chapter 3. In Chapter 4 he arrived in a holding pen and intimidated a guard into lowering his staff. He remains captive, cannot understand the local language, and sees unchanged, unexplained 1/1 numbers.'
foreach ($arc in $state.Arcs | Where-Object Status -ne 'Completed') {
    $arc.CurrentPhase = $phase
    if ($arc.Status -eq 'Active') {
        $arc.NextMilestone = 'Establish how Caelen can secure basic necessities in the holding pen after his confrontation with the guard, without mistaking that reprieve for freedom, rank, or System advancement.'
    } else {
        $arc.NextMilestone = 'After the preceding arc is resolved, advance this arc from the established captivity continuity; do not repeat death, the void, resurrection, or initial capture.'
    }
}
$medium = @($state.Arcs | Where-Object Id -eq $prefix)[0]
$medium.Objective = 'Caelen must move from death and disoriented resurrection into a concrete understanding of his immediate captivity, finding a bounded way to endure the local slave system without yet understanding the System or speaking the language.'
$medium.ResolutionCriteria = 'Death, the void, resurrection, assessment and capture are established by Chapters 1-3. By the end of this arc Caelen has tested the limits of intimidation, negotiated immediate survival in captivity, and entered an identifiable daily obligation with a limited next step. He remains enslaved; fluency, deliberate System advancement, rebellion and escape remain unresolved.'
$current.PrimaryTrope = 'Testing the Cage'
$current.Objective = 'Caelen must establish the limits of personal intimidation inside the holding pen and find a workable means of securing immediate necessities while remaining captive.'
$current.ResolutionCriteria = 'Caelen has faced the pen hierarchy, tested the consequences and limits of his confrontation with the guard, and made a bounded arrangement for immediate survival. He has neither escaped nor acquired formal authority or a confirmed System increase.'
$current.CompletedMilestones = @([pscustomobject]@{ ChapterNumber = 4; Development = 'Caelen enters the holding pen, observes the masked man dismiss its dominant prisoner, and uses a wordless bluff to make a guard lower his staff. He secures a momentary boundary for himself, remains captive, and sees unchanged 1/1 numbers.' })
$next.PrimaryTrope = 'The Terms of Survival'
$next.Objective = 'After stabilizing immediate survival in the pen, Caelen must discover the practical obligations imposed on him and choose a limited way to meet them without surrendering all agency.'
$next.ResolutionCriteria = 'Caelen understands one concrete daily obligation through observation and gestures, experiences its cost, and establishes a repeatable means of meeting it with a bounded next step. He remains enslaved and lacks fluency and a reliable explanation of the System.'
$reserved = @('Escape, rebellion, formal authority over prisoners and a covert army.', 'Fluent local language and deliberate, confirmed advancement of either System path.', 'Replaying death, the void, resurrection or initial capture as future events.')
function New-Target($sequence, $chapter, $question, $objective, $change, $choice, $discovery, $closing, $other, $relationship, $contribution) {
    [pscustomobject][ordered]@{
        Sequence = $sequence; ChapterNumber = $chapter; DramaticQuestion = $question
        Objective = $objective; IntendedChange = $change
        CharacterDevelopmentTarget = 'Show how Caelen distinguishes protecting his own position from helping another captive, through the bounded choice assigned here.'
        RelationshipTargets = @([pscustomobject][ordered]@{
            CharacterAId = 'Caelen'; CharacterBId = $other
            StartingDynamic = 'Caelen is a captive with little reliable knowledge of the people around him.'
            IntendedChange = $relationship
            Tension = 'A useful exchange or concession can be withdrawn by someone with greater power.'
            PowerDynamic = 'The captors retain institutional control; Caelen has only situational influence.'
            Subtext = 'Caelen seeks security while judging other people for their utility.'
            PreservedBoundary = 'No friendship, formal authority or freedom is established merely by a successful interaction.'
            ReservedLaterWork = @('Lasting loyalty, organized resistance and emancipation.')
        })
        WorldbuildingTargets = @('Make the immediate constraints of captivity visible through actions, gestures and material necessities rather than fluent exposition.')
        Complications = @('Caelen cannot understand the local language and remains subject to the guards.')
        RequiredChoice = $choice
        Consequences = @($change)
        DiscoveryTarget = $discovery
        SetupElements = @('The difference between a temporary concession and lasting power.')
        PayoffElements = @('Caelen uses his established ability to observe threats while confronting its limits.')
        ThematicPressure = 'Survival through control can reproduce the treatment of people as assets.'
        ResolutionContributions = @($contribution)
        ReservedLaterWork = $reserved
        ClosingState = $closing; IsCompleted = $false; CompletedInChapter = $null; CompletionEvidence = @()
    }
}
$t4 = New-Target 1 4 'Can Caelen establish a personal boundary without freedom or a shared language?' 'Depict arrival in the holding pen, its imposed hierarchy, and a wordless confrontation in which Caelen intimidates a guard to secure his own immediate position.' 'Caelen moves from transported captive to an active observer who obtains a temporary reprieve through a bluff.' 'Use intimidation for immediate self-preservation rather than offer submission or launch an escape.' 'The guard can retreat from an immediate confrontation while the surrounding system retains control.' 'Caelen sits in the pen after the guard lowers his staff; the 1/1 numbers have not changed.' 'The pen guard' 'The guard lowers his staff and steps back after Caelen approaches and gestures.' 'Establish the initial boundary whose reliability remains to be tested in Chapters 5-6.'
# Retrospective editorial correction, not approval of the superseded void target.
$t4.CharacterDevelopmentTarget = 'Show Caelen acknowledging that his intervention serves his own security, with no confirmed moral or System advancement.'
$t4.RelationshipTargets[0].StartingDynamic = 'The guard points at the newly arrived captive and raises his staff.'
$t4.RelationshipTargets[0].Tension = 'The bluff risks a beating because Caelen has no weapon, backup or knowledge of local rules.'
$t4.SetupElements = @('The guard and other prisoners continue watching Caelen after the confrontation.')
$t4.PayoffElements = @('Threat assessment learned as a Marine informs the wordless bluff.')
$t4.IsCompleted = $true
$t4.CompletedInChapter = 4
$t4.CompletionEvidence = @(
    'He was shoved into a line. Or rather, he was herded into a pen.',
    'The guard stared at him for a long, agonizing second. Then, he lowered his staff. He stepped back.',
    'He had acted to secure his own position. He had used his strength, his training, and his intimidation to manipulate a situation to his advantage.',
    'They were steady. Unchanging.'
)
$prose = Get-Content -Raw -LiteralPath (Join-Path $storyRoot 'build/chapters/chapter-004/final.md')
foreach ($quote in $t4.CompletionEvidence) { if (-not $prose.Contains($quote)) { throw "Missing Chapter 4 evidence: $quote" } }
$t5 = New-Target 2 5 'Does the boundary Caelen established secure anything he needs?' 'Test the practical limits of the guard confrontation through one immediate need, such as water, food or a place to rest, inside the holding pen.' 'Caelen learns one concrete limit of intimidation and obtains or fails to obtain a specific necessity at a visible cost.' 'Choose between escalating his bluff and using observation or a limited exchange to address that need.' 'Personal intimidation does not remove the captors control over necessities.' 'The immediate need has an observable outcome, and Caelen recognizes what an enduring arrangement would require.' 'A fellow captive' 'A narrowly useful exchange or refusal clarifies whether this person will cooperate over the immediate need.' 'Expose the limits that a workable survival arrangement must address; do not finalize that arrangement yet.'
$t6 = New-Target 3 6 'Can Caelen convert a temporary reprieve into a workable survival arrangement?' 'Use the limits learned in Chapter 5 to negotiate or accept one bounded arrangement for basic necessities within the pen.' 'Caelen gains a concrete means of enduring immediate captivity and accepts an explicit cost or obligation.' 'Accept a constrained obligation or forgo its benefit; show his choice and its immediate consequence.' 'A repeatable arrangement is possible without ownership of his own future.' 'The immediate holding-pen survival problem has a workable arrangement; its wider obligations remain for Chapters 7-9.' 'A guard or overseer' 'A concrete exchange establishes what Caelen must do and what he receives in the pen.' 'Resolve immediate survival within the pen without resolving enslavement, language acquisition or System mechanics.'
$current.ChapterTargets = @($t4, $t5, $t6)
$t7 = New-Target 1 7 'What does the survival arrangement require of Caelen each day?' 'Introduce one concrete daily duty or demand that follows from the established arrangement, communicated through observation and gestures.' 'Caelen understands the immediate task and the consequence of refusing it.' 'Attempt the assigned task or openly resist its immediate terms.' 'The local order enforces obligations through practical control, even after granting a concession.' 'The first duty is identified and attempted, with a specific difficulty still unresolved.' 'An overseer' 'The overseer establishes a concrete demand without granting Caelen rank or freedom.' 'Establish the obligation that must be made workable in the remaining chapters.'
$t8 = New-Target 2 8 'Whose cost makes Caelen useful to his captors?' 'Complicate the daily duty with a concrete cost to Caelen or another captive, forcing a bounded adjustment.' 'Caelen sees the human cost of a tactic that improves his own position and chooses how to respond.' 'Keep the benefit at another captives expense or accept a limited personal cost to alter the outcome.' 'Usefulness to captors and safety for fellow captives are not the same thing.' 'The immediate cost is confronted, but a reliable way of meeting the obligation is not yet settled.' 'A fellow captive' 'A specific choice changes this persons willingness to cooperate, without establishing lasting loyalty.' 'Expose the cost that the final working routine must account for.'
$t9 = New-Target 3 9 'Can Caelen establish a limited next step without mistaking survival for freedom?' 'Resolve the immediate duty problem through a repeatable approach grounded in Chapters 7-8 and identify one bounded next step for learning local life.' 'Caelen has a practical foothold and recognizes the constraints he still cannot change.' 'Commit to a sustainable limited approach rather than risk an unsupported escape or claim authority.' 'He can act deliberately within captivity while still lacking language, freedom and System knowledge.' 'An identifiable daily obligation is workable; the next arc can begin functional language learning and cautious experimentation.' 'An overseer' 'A demonstrated routine clarifies the practical terms of Caelens continued captivity.' 'Complete the initial adaptation to captivity while reserving language acquisition and deliberate path advancement for later arcs.'
$next.ChapterTargets = @($t7, $t8, $t9)
$state | ConvertTo-Json -Depth 50 | Set-Content -LiteralPath $arcPath -Encoding utf8
$audit = [ordered]@{
    RepairType = 'Editorial continuity reconciliation against finalized prose'
    Date = '2026-10-04'
    Reason = 'The completed first Short arc already covers the void and resurrection; the second and third arcs erroneously schedule those events again.'
    SupersededPlan = 'STORY-ARCS.before.json'
    Chapter4Disposition = 'Replaced the impossible void assignment with an evidenced retrospective captivity target. This does not assert completion of the old target.'
    Evidence = $t4.CompletionEvidence
    FutureWork = 'Chapters 5-9 remain incomplete. Arc IDs, chapter ranges, statuses and completed Chapters 1-3 were retained.'
    ProseSHA256 = $beforeHashes
    PriorModelResults = 'Existing extraction, rejection and application receipts remain historical records of the pre-repair plan; no model approval has been fabricated.'
}
$audit | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'repair-record.json') -Encoding utf8
Write-Output 'Saved repaired arc plan, original backup and editorial evidence record.'
