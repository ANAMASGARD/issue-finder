## What it does

Checks whether a confirmed finding has already been reported, fixed, or discussed, across every forge the target project uses. The defining constraint: a title match or mismatch alone is never enough, every plausible hit's body gets read before a verdict is recorded.

## When to reach for it

- Invocation mode: model-invoked. Call it by name, or `issue-finder` calls it automatically after `verifying-findings` confirms a candidate.
- Reach for this directly for a standalone question like "has this already been reported upstream?" without needing a full verification pass first.

## Prerequisites

A confirmed candidate with a clear symptom, error text, and (if traced) the affected code symbols, so a real query set can be built.

## The query set and the recheck

Builds queries from the symptom, exact error text, component and configuration keys, code symbols, and the underlying mechanism, plus a broader and a narrower variant of each. Runs them across issues, PRs in every state, discussions, commits, changelogs, and advisories, using `FORGES.md`'s recipes for `gh`, `glab`, Gitea/Forgejo, Bugzilla, Jira, Launchpad, mailing lists, and OSV. The screen is re-run immediately before anything is actually published, not just once earlier in the engagement.

## It's working if

- Every query run is recorded, including the ones that found nothing.
- A near-duplicate gets linked explicitly in the draft rather than silently dropped or silently duplicated.
- The screen was re-run right before publishing, with a fresh timestamp, not reused from earlier in the engagement.

## Where it fits

Sits between `verifying-findings` and `drafting-issues`. A duplicate found here changes the disposition (`Confirmed but already reported` or `Already fixed upstream`) rather than producing a separate draft.
