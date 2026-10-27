# Validation ladder and PR draft

## The ladder

Run every command `issue-finder`'s `PROJECT.md` recorded from CI, in this order, against the fix branch's `HEAD`. Use the project's own flags exactly as CI runs them, not a looser local variant:

1. The new regression test, alone, and it must pass.
2. The original reproduction from the finding's record, and it must now show the expected behavior, not just "no crash."
3. The affected package/module's test suite (narrower, faster signal before the full run).
4. Install (clean, matching CI: `npm ci`, `pip install -r requirements.txt --no-cache-dir`, etc., not a looser local-only variant).
5. Lint / format check.
6. Typecheck, if the project has one.
7. The full test suite.
8. Build.
9. End-to-end tests, if CI runs them and they work in this sandbox; if they need infrastructure this sandbox doesn't have, say so explicitly rather than skipping silently.

For a performance fix, add: the same benchmark run 5 or more times on both baseline and fixed `HEAD`, reported as median and spread for each, not a single run of each.

## Pass criteria

Compare every result against `issue-finder`'s baseline table in `REPORT.md`, not against an assumption of "should all be green":

- No command that passed at baseline may fail now.
- A command that already failed at baseline may still fail now, but only with the exact same failure (same test names, same count); a *new* failure mixed into an old one is not a pass.
- Record each command, PASS/FAIL, and the `HEAD` SHA it was run at, for the report.

## If it doesn't pass

Fix and re-run. Allow at most 3 rounds total. If still failing after 3, stop, record exactly what's failing and your best explanation, and report `BLOCKED` rather than forcing a fourth attempt or weakening the regression test to pass.

## PR draft

Write this to `.issue-finder/drafts/fix-<IF-###>.md`, local only. Opening the actual PR is a separate, explicitly authorized action, never implied by finishing the fix.

```markdown
# Fix: <finding title> (IF-###)

**Branch:** fix/<slug>, based on <primary>@<base SHA>
**Finding:** .issue-finder/findings/IF-###.md

## Summary

<One paragraph: what was wrong, what changed, why this is the smallest fix for the traced root cause.>

## Before / after

**Before (reproduction):**

    <the original failing output>

**After (same reproduction, same command):**

    <the now-correct output>

## Regression test

<Path to the new test, and the one sentence it would catch if this fix were reverted.>

## Validation

| Check | Command | Result | HEAD SHA |
|---|---|---|---|
| Regression test | `...` | PASS | `...` |
| Original reproduction | `...` | PASS | `...` |
| Full suite | `...` | PASS | `...` |
| Lint | `...` | PASS | `...` |
| Typecheck | `...` | PASS | `...` |
| Build | `...` | PASS | `...` |

## Diff stat

`<git diff --stat output>`

## Review

<Summary of the independent review pass: who/what reviewed it, and what it found, if anything.>

---
Not pushed, no PR opened. This draft is for your review before either happens.
```
