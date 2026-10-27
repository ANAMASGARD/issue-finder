# Scoring: confidence, priority, difficulty

Score every lead the same way, right after you reproduce it. No judgment calls where a checklist will do.

## Finding record

One file per lead, `.issue-finder/findings/IF-###.md`, written as soon as you reproduce it:

~~~~markdown
# IF-001: <one-line title>

**Command:** `<exact command you ran>`
**Output:**
```
<exact output, trimmed to the relevant lines>
```
**Expected (per <doc/spec/test/type>):** <quote or close paraphrase, with a path or URL>
**Root cause:** `<file>:<line>` <one sentence>
**Reproduced:** <N> of <N> runs

**Confidence:** <score>/10 (<breakdown, one line per point source>)
**Priority:** P<0-3> (<one-line reason>)
**Difficulty:** <score>/10 (<one-line reason>)
**Duplicate check:** <what you searched, and what you found or didn't>
~~~~

## Gate

A lead you could not reproduce yourself gets no score. List it under "Unconfirmed" in the report with what you tried and why it didn't reproduce. Zero confirmed findings is a complete, successful result; never inflate a score to avoid reporting zero.

## Confidence (0 to 10)

Sum these. Each one needs the evidence it names, not an impression:

| Points | Criterion |
|---|---|
| +3 | Reproduced on the synced base SHA, with the real command and real output quoted in the record |
| +1 | Reproduced in 3 of 3 runs (skip for a build/install failure that's obviously deterministic; note why) |
| +2 | Expected behavior is backed by a primary source: the project's own docs, a spec, an existing test, or a type signature, quoted or linked |
| +2 | Root cause pinned to a specific file and line, not just a symptom |
| +1 | Survived a skeptic pass: dispatch a subagent with only the claim and the repo (no prior framing) and ask it to refute the claim using the code and docs. Tell it explicitly that a wrong refutation costs double the claim's eventual priority weight, so it should only refute when it actually finds contradicting evidence. The point is earned when it fails to refute, or confirms. If it successfully refutes, drop the finding instead of scoring it. |
| +1 | No existing issue, PR, or fix found for it: `gh issue list --search "<terms>"`, `gh pr list --search "<terms>"`, `git log -S"<term>" --oneline` / `git log --grep="<term>" --oneline` all checked |

**Bands:** 7-10 is confirmed, report it. 4-6 needs a maintainer's judgment call the evidence can't settle alone (e.g., "is this actually a bug or intentional"); report it, flagged, and say what's unresolved. Below 4: drop it, don't report it, but keep the record for your own trail.

## Priority

Pick the highest one that applies:

| Priority | Criteria |
|---|---|
| P0 | Security vulnerability, data loss or corruption, a crash on the documented main path, or the project fails to build or install following its own instructions |
| P1 | A core documented feature produces wrong output or doesn't work, with no reasonable workaround |
| P2 | A secondary feature is broken, or P1-level wrongness that has a documented or obvious workaround |
| P3 | An edge case, a cosmetic issue, a docs/behavior mismatch with no functional impact, or a missing nice-to-have |

## Difficulty (0 to 10)

Estimate the fix, not the investigation already done:

| Score | Shape of the fix |
|---|---|
| 0-2 | A local change in one function, and an existing test already covers the behavior or can trivially be extended |
| 3-4 | One module, plus a new test at an existing seam |
| 5-6 | Several files, or a new test seam needs to be built |
| 7-8 | Crosses components, changes a public API/contract, or needs a data migration |
| 9-10 | No clear fix without a maintainer design decision (the finding is real, but "fix" isn't a coding task yet) |

## Special cases

**Security.** Score normally, but the finding's full detail (reproduction, root cause, impact) lives only in `.issue-finder/private/`, never in the public report, never in a commit message, never in a branch name. The scorecard shown to the user names only "Security finding (details in private/)" with its confidence and priority; nothing else leaks into shared output.

**Performance.** Needs a named metric (latency, memory, throughput) and 5 or more runs, reported as median and spread (min-max or stdev), compared against a documented target or the same metric on the unmodified baseline. A single slow run is a lead, not a finding, until repeated.

**Flaky.** Report the observed failure rate over however many runs you did (e.g., "3 of 10 runs failed"), and don't claim a root cause you haven't actually isolated; "intermittent, cause unknown" is an honest, valid finding on its own.

## Sorting the scorecard

Rank by priority first (P0 highest), then confidence (higher first), then difficulty (lower first, since an easy P0 fix should sit above a hard one of the same priority).
