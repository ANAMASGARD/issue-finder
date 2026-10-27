## What it does

Decides whether a lead is a real, reproducible finding. The defining constraint: it does not accept a lead as confirmed until a real attempt to disprove it has failed, and it never lets code-reading alone earn a "confirmed" verdict, only actual execution does.

## When to reach for it

- Invocation mode: model-invoked. Call it by name, or `issue-finder` calls it automatically after the Hunt phase produces candidates.
- Reach for this directly for a standalone question like "is this a true bug or a false positive?" without running a full hunt first.

## Prerequisites

A specific candidate claim, stated clearly enough to restate in your own words. If you can't restate it clearly, that's the first thing to resolve, half of false leads collapse at that step alone.

## The six gates and seven dispositions

Every candidate is checked against a version-correct contract, a reachable path, a red reproduction (run twice on a pinned baseline, then minimized), a root cause traced to its origin, a negative control plus a real disproof attempt, and stated proof boundaries with impact and scope. It ends in exactly one of seven dispositions, from `Confirmed and actionable` down to `Rejected hypothesis`, with `Security-sensitive: private handling required` overriding every other one the instant it applies.

## It's working if

- Every "confirmed" finding's record has evidence recorded against all six gates, not just an assertion.
- A rejected hypothesis stays in the record with its reasoning, rather than being silently deleted.
- Severity never exceeds what was actually demonstrated.

## Where it fits

Sits between `exploratory-testing` (which produces leads) and `screening-duplicates` (which checks whether a confirmed finding is already known). `issue-fixer` starts from this skill's record, not from a fresh guess at the root cause.
