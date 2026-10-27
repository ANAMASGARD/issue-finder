## What it does

Turns a confirmed, screened finding into a local draft, ready for a human to review and decide whether to file. The defining constraint: it never files anything itself, and it never drafts a public artifact for a finding disposed `Security-sensitive`.

## When to reach for it

- Invocation mode: model-invoked. Call it by name, or `issue-finder` calls it automatically once a finding is confirmed and screened.
- Reach for this directly to write up one specific finding you already have a clear record for.

## Prerequisites

A finding record with disposition `Confirmed and actionable` or `Security-sensitive: private handling required`, already screened by `screening-duplicates`.

## Policy preflight and the fresh-eyes check

Reads the target project's own issue templates, `CONTRIBUTING` file, AI-contribution policy, `SECURITY.md`, and DCO rules before drafting anything; real projects disagree sharply here (see `AI-DISCLOSURE-POLICIES.md` for concrete examples), so the specific target is always checked, never assumed. Before a draft is final, a fresh subagent or a clean rerun must reproduce the bug from the draft's own steps alone, with no access to the investigation notes; a confirmed bug with bad repro steps in the draft helps nobody.

## It's working if

- The draft lives in `.issue-finder/drafts/` (or `.issue-finder/private/`, mode 0600, for a security advisory), not just in chat.
- The fresh-eyes check actually ran and passed before the draft was called final.
- A bug report never pitches its own fix in the title or description.

## Where it fits

The last discipline before the final report. Publishing the draft (opening the actual issue, PR, or sending the private report) is a separate action that needs its own explicit authorization in `ENGAGEMENT.md`.
