# Report: the scorecard and `REPORT.md`

## The scorecard, shown in chat

One row per confirmed finding (confidence 7+), sorted per `scoring.md`'s rule. Needs-judgment findings (confidence 4-6) go in a second, clearly separate table. Keep titles to one line; link each ID to its finding file.

```text
Confirmed findings

Rank  ID      Finding                               Confidence  Priority  Difficulty
1     IF-002  Crash on an empty input file          8/10        P0        3/10
2     IF-001  Documented --verbose flag is ignored  9/10        P1        2/10

Needs your judgment (confidence 4-6)

ID      Finding                                      Confidence  Open question
IF-003  Retry count looks low for documented SLA     5/10        Intentional, or should it be configurable?
```

After the table, ask which one (if any) to fix now, naming the top-ranked ID as the default. Security findings appear only as "Security finding (details in private/)" with confidence and priority, never a description, in any chat output or the public `REPORT.md`.

## `.issue-finder/REPORT.md`

```markdown
# Issue Finder report: <repo name>

**Run date:** <date>
**Synced to:** <primary branch>@<base SHA> (<remote>)
**Hunt branch:** <bughunt/... branch name>
**Project type:** <from project-types.md>
**Environment:** <what you ran it in, and why, per project-types.md>

## Baseline

| Check | Result |
|---|---|
| Install | PASS/FAIL |
| Lint | PASS/FAIL |
| Typecheck | PASS/FAIL |
| Test | PASS/FAIL |
| Build | PASS/FAIL |

A baseline failure is itself a finding; it has its own IF-### row below.

## Confirmed findings (confidence 7+)

One subsection per finding, each linking to its `findings/IF-###.md`: title, confidence breakdown, priority, difficulty, one-paragraph summary.

## Needs your judgment (confidence 4-6)

Same shape, plus the specific open question that evidence alone couldn't settle.

## Dropped (confidence below 4, or disproved)

One line each: ID, title, why it was dropped (disproved by the skeptic pass, already fixed upstream, duplicate of #N, etc.).

## Unconfirmed (could not reproduce)

One line each: what you tried, what capability or access was missing.

## What happened to git

State of the hunt branch, stash (restore command if one exists and wasn't needed), and confirm nothing was pushed, committed to the user's original branch, or opened anywhere.

## Next step

Name the finding you'd recommend fixing first and why (usually the top scorecard row), and that `issue-fixer` is available by naming an ID.
```

Revert any temporary instrumentation added during the hunt before writing this file, and say explicitly that you did.
