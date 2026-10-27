## What it does

Fixes exactly one confirmed finding, with a failing regression test written before any fix, and an independent review before a PR draft. The defining constraint: a confirmed finding alone does not authorize touching source; that authorization is separate and must already be granted, or asked for explicitly, before this skill does anything.

## When to reach for it

- Invocation mode: user-invoked. You type `/issue-fixer IF-###`; it never fires on its own, and `issue-finder` never calls it automatically, even after a full hunt.
- Reach for this once you've reviewed a specific finding's record and decided you want it fixed locally.

## Prerequisites

A finding record disposed `Confirmed and actionable` (or a security-sensitive one, prepared locally only, never opened as a public PR). `ENGAGEMENT.md` must grant "local branch and source changes", or this skill asks for that authorization before proceeding.

## Safe sync, red-green, and the PR draft

Re-fetches the upstream default branch and reruns the finding's minimal reproduction on the fresh commit before touching anything; if it no longer fails, the disposition becomes `Already fixed upstream` and no branch gets created. Otherwise: a project-native branch name (`BRANCHING.md`), a failing regression test written first, the smallest fix for the already-traced root cause, the full validation ladder (`VALIDATION.md`), an independent review, and a local PR draft (`PR-DRAFT.md`). Opening the actual PR needs its own separate authorization.

## It's working if

- The regression test failed for the right reason before the fix, and passes after it.
- The diff contains only the traced fix, with no unrelated cleanup or refactoring riding along.
- The branch name follows the project-native pattern, never an `ai/`, `agent/`, or `codex/` prefix.

## Where it fits

The only skill in the suite that writes to the target's source. Runs once per finding, after `issue-finder`'s full pipeline has already produced a confirmed, screened record for that specific finding.
