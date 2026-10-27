# Ranking confirmed candidates

Score every candidate with the disposition "Confirmed and actionable" on each criterion from 1 to 5, weighted:

| Criterion | Weight | What earns a 5 |
| --- | --- | --- |
| Real end-user impact | 30% | Breaks a documented, commonly used workflow for supported users |
| Reproduction quality and confidence | 25% | Deterministic, minimized, reproduces twice on a pinned baseline, clear root cause |
| Maintainer and roadmap alignment | 20% | Fits the project's own stated direction; not something they've already rejected |
| Feasibility and bounded scope | 15% | A small, well-scoped fix is plausible at the traced root cause |
| Architectural learning / cross-component relevance | 10% | Reveals something true about more than one call site or component |

Total = sum of (score x weight), out of 100.

Only candidates scoring **at least 70** proceed automatically to `drafting-issues`. Below 70, record the score and reasoning in the candidate's record and leave its disposition as "Confirmed and actionable (below ranking bar)"; mention it in the final report, but don't draft it unless the user explicitly asks for that specific one. State any exception to the 70-point default explicitly, with why.

This score never substitutes for the evidence gates in `verifying-findings`. A candidate without a traced root cause and a disproof attempt never reaches this scoring step regardless of how high it would score.

Security severity is scored separately, by demonstrated impact (see `verifying-findings/references/SECURITY-CANDIDATES.md`), never folded into this 100-point scale.
