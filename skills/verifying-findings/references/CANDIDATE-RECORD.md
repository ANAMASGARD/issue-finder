# Candidate record format

## `.issue-finder/candidates.md` — the ledger

One row per candidate, updated as its status changes:

```markdown
| ID | Summary | Status | Disposition | Record |
| --- | --- | --- | --- | --- |
| IF-001 | Config loader ignores `--config` when a default config also exists | verified | Confirmed and actionable | findings/IF-001-config-loader-ignores-flag/record.md |
```

Status is one of: `new`, `verifying`, `verified`, `screened`, `drafted`. Never delete a row, even for `Rejected hypothesis`; a complete ledger is part of the evidentiary trail.

## `findings/IF-###-<slug>/record.md` — the full record

```markdown
# IF-### <slug>

## Lead
Where this came from (journey ID / hunting lane / variant search), one line.

## Claim, restated
Your own words, confirming you understand what's being tested before analyzing it.

## Gate 1: Version-correct contract
What the expected behavior is, with its exact source (file:line, doc section, spec clause) at the commit under test.

## Gate 2: Reachable path
How this is reached in a configuration the project actually supports. Cite the call path or user-facing trigger.

## Gate 3: Red reproduction
- Baseline commit SHA.
- Exact minimal command/request/input.
- Run 1 output (verbatim, redacted).
- Run 2 output (verbatim, redacted) — confirms it's not a fluke.
- Minimization: what was removed/simplified from the original repro and confirmation it still fails.

## Gate 4: Root cause
File:line and mechanism. The introducing commit, if found.

## Gate 5: Negative control and disproof attempt
What comparison case was run and that it passed as expected. What alternate explanations were actively checked (already fixed, intended, environment issue) and how each was ruled out.

## Gate 6: Proof boundaries, impact, scope
What was tested and what wasn't (see PROOF-BOUNDARIES.md). Affected users/versions/configurations, based only on what was demonstrated.

## Disposition
One of the seven, with a one-line justification.

## Evidence
Links/paths to captured output, screenshots, logs — all redacted.
```

A record missing any gate's evidence cannot be disposed `Confirmed and actionable`; it stays `verifying` until the missing gate is filled in or the candidate is disposed some other way.
