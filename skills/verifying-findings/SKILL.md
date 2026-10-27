---
name: verifying-findings
description: Decide whether a lead is a real, reproducible finding, using evidence gates and a fixed disposition taxonomy, before anything gets screened for duplicates or drafted into a report. Use when asked to verify, confirm, triage, or judge whether a suspected bug or vulnerability is real.
---

# Verifying Findings

A lead is not a finding until it survives every gate below. Most leads should die here; that is the gate working, not the gate failing.

## Non-negotiables

1. **Reading code is never enough on its own.** A candidate whose only evidence is "I read the code and it looks like it would fail" gets the disposition `Needs additional runtime validation`, never `Confirmed and actionable`, until it has actually been executed.
2. **Severity never exceeds demonstrated impact.** You may only claim the impact you actually produced or can rigorously, specifically argue from what you produced. Worst-case theoretical impact is not a substitute for a demonstration.
3. **Try to kill it before you believe it.** Every candidate gets a real attempt at disproof: a negative control, an alternate explanation actively sought, a check of whether the "bug" is actually documented, intended, or already fixed. If you cannot produce a disproof attempt, say explicitly what you tried and why it didn't settle the question, don't skip the step.
4. **One wrong quote poisons the whole report.** Every claim about code or output must cite an exact file:line or command output you actually captured, quoted verbatim. Never paraphrase a quote from memory.
5. **Security-sensitive findings get the overriding disposition.** The instant a candidate's impact involves unauthorized access, data exposure, privilege escalation, or similar, it becomes `Security-sensitive: private handling required` regardless of what else is true about it, and every other authorization (public issue, PR, disclosure) is void for that candidate until the user explicitly grants private-handling authorization in `ENGAGEMENT.md`.
6. **Redact secrets** in every piece of captured evidence before it's written anywhere.
7. **Restate the claim before analyzing it.** Put the suspected bug in your own words first. If you can't state it clearly, that confusion is itself informative, ask for clarification rather than analyzing a claim you don't actually understand yet.

## The gates

A candidate must pass all six before it can be considered for `Confirmed and actionable`. Record the evidence for each gate in the candidate's record (see [references/CANDIDATE-RECORD.md](references/CANDIDATE-RECORD.md)); a gate with no recorded evidence is a gate that wasn't actually passed.

1. **Version-correct contract.** State exactly what the expected behavior is, cited from the current docs, spec, comment, or test at the exact commit under test, not from memory or a different version. If no contract can be found, that absence is itself worth noting, but there is nothing to verify a violation against yet.
2. **Reachable path.** Confirm the affected code path is actually reachable in a configuration this project supports today. Code nothing reaches today is still worth recording, at lower severity, never dismissed outright as a false positive just because it's currently unreachable.
3. **Red reproduction.** Reproduce the failure at the project's real public interface (CLI, API, UI, library call), not an internal function called directly, unless the internal function *is* the public interface. Run it twice on a pinned baseline commit to rule out a fluke, then minimize it to the smallest input/command that still fails.
4. **Root cause traced to origin.** Trace the failure to its actual source location and mechanism, not just the symptom. If you can identify the commit that introduced it, note that too; it's useful for duplicate screening and for the fixer.
5. **Negative control and a real disproof attempt.** Run a comparison case that should *not* fail and confirm it doesn't, and actively look for the mundane explanation: already-fixed upstream, intended behavior, environment misconfiguration, stale baseline.
6. **Proof boundaries, impact, and scope stated.** Say exactly what you did and didn't test (see [references/PROOF-BOUNDARIES.md](references/PROOF-BOUNDARIES.md)), and state impact and affected scope (which users, versions, configurations) based only on what you demonstrated.

Route to specialized gates when the candidate needs them:

- Security impact (unauthorized access, injection, escalation, data exposure): [references/SECURITY-CANDIDATES.md](references/SECURITY-CANDIDATES.md). Read this before you do anything else with the candidate, since it changes the disposition and authorization model.
- Performance regression or resource-usage claim: [references/PERFORMANCE-EVIDENCE.md](references/PERFORMANCE-EVIDENCE.md).
- Intermittent, racy, or otherwise nondeterministic reproduction: [references/NONDETERMINISTIC.md](references/NONDETERMINISTIC.md).

See [references/WORKED-EXAMPLE.md](references/WORKED-EXAMPLE.md) for all six gates walked through end to end on one concrete (generalized, fictional) case.

## Disposition

Every candidate ends in exactly one of these seven. Pick the single best match; don't invent an eighth.

| Disposition | Means |
| --- | --- |
| **Confirmed and actionable** | All six gates passed; nothing else below applies. |
| **Confirmed but already reported** | All six gates passed, and `screening-duplicates` (or your own check) found it's already filed. |
| **Already fixed upstream** | Reproduces on the pinned baseline but not on the current upstream default branch. |
| **Enhancement requiring maintainer discussion** | Not a contract violation, a reasonable gap or improvement with no existing contract to violate. |
| **Needs additional runtime validation** | A specific, source-grounded hypothesis exists but could not be executed to confirm (missing sandbox capability, external dependency unavailable, etc.). Never used as a label for a low-confidence "confirmed" bug; say explicitly what's blocking execution. |
| **Rejected hypothesis** | The disproof attempt succeeded: intended behavior, already-correct, or the reasoning doesn't hold up. Keep it in the record; a rejected hypothesis with its reasoning is valuable, don't delete it. |
| **Security-sensitive: private handling required** | Overrides every other disposition and every other authorization the moment it applies. |

## Output

Update `.issue-finder/candidates.md` and the candidate's own `findings/IF-###-<slug>/record.md` with the disposition and all six gates' evidence. Only candidates disposed `Confirmed and actionable` or `Security-sensitive` continue to `screening-duplicates` and then `drafting-issues`.
