# As the World Rolls — editorial recovery

The author fixed the canon boundary at **Chapter 14: The Gate of Silence** and authorized rebuilding Chapters 15–18 into an ending at 18. Every protected chapter file from 1 through 14 is byte-for-byte unchanged, verified against SHA-256 hashes saved before editing.

## Replacement continuation

| Chapter | Title | Narrative work |
|---|---|---|
| 15 | The Broken Valve | Continue the stronger pull begun in 14; survive the quartz failure; test a fragment arrangement that removes the need for a permanent human hold. |
| 16 | The Last Note | Redirect the local feed into the distant temple barrier; observe the pressure cease; close and test the groove; leave together. |
| 17 | The Road Back | Show the actual return, treatment, candid debrief, equipment accounting, and transfer of the next watch. |
| 18 | A Place at the Table | Corroborate the outcome independently, document its limits, and give all five a stable ending without another contract or urgent summons. |

The four chapters retain approximately 97–99% of their original lengths. Repeated explanations and unearned claims were replaced with decisions, tests, mistakes, physical consequences, and human aftermath. This was a full editorial rebuild, not an automated polish pass.

## Continuity repairs

- The Gate of Silence shrine and the consuming temple barrier remain separate sites.
- Quartz fragments stay in the groove until the operation closes; no one packs away a key still needed to maintain an active channel.
- Physical heat can char wood; a leather sling holds positions rather than magically containing the whole pressure.
- Elara discovers a workable repair through tests instead of finding a conveniently prewritten protocol.
- Kaelen's limits matter. The channel holds after the party moves outside range; he is not secretly maintaining it from a tavern.
- The local operation is completed and independently corroborated. Universal eradication, city safety, and the enormous silhouette's death are not invented.
- The forest keeper remains an acknowledged unknown, not an urgent unresolved task or final-page cliffhanger.
- Silas Vane, Temple Springs cargo, the alchemist deal, lunar-cycle theory, sulfur-paste repellent, and caravan departure from the superseded continuation no longer enter current canon or character state.

## Workspace reconciliation

The active publication, production manuscript copies, and build `draft.md`/`final.md` files agree. Narrative, character, world, canon, thread, and arc context were reconciled with the replacement prose. Changed completed-target receipts point to actual sentences in that prose. Earlier target history through Chapter 14 was retained.

The fixed 3/9/27/81 hierarchy remains structurally valid. Its unused future slots are explicitly series reserves; the larger arcs are not falsely marked completed. Those slots do not represent a missing ending in this episode.

The existing `run.bat` checks `.storyforge/episode-complete.json` and stops at 18. It does not start the next episode. Direct Worker CLI commands do not consult that launcher marker and should not be used to continue this closed episode. A new episode should use a separate workspace with a fresh self-contained premise and selectively carried-forward cast/world context.

Superseded mutable build folders, rejected attempts, diagnostics, later scripts, and any later final audio encountered were archived, not deleted. Original context and manuscript copies are also saved at `.storyforge/editorial-recovery/20261012-115913`. Old review, state-extraction, and generation-time records are not retained as approval of the replacement prose. No live model-review result or regenerated audio is claimed.

## Checks and reading copy

Engine arc validation, changed completion-evidence checks, protected chapter hashes, chapter-copy equality, the prose rule against one-word narrative sentences, and the launcher stop behavior were checked. These checks establish structure and preservation; literary quality remains a reader's judgment.

`As-the-World-Rolls.md` is the combined reading copy. Chapters 1–14 retain their narrative text; the reading copy omits generation-information footers without changing the protected chapter files. Chapters 15–18 contain the replacement ending. The per-chapter files remain in `publication/chapters`.
