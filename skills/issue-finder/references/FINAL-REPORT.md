# `REPORT.md` template

Lead with outcomes, then evidence. Write to `.issue-finder/REPORT.md`.

```markdown
# Issue Finder report: <target>

## Repository state

- Target and canonical upstream, exact SHA investigated.
- Source/release/package boundary tested (see REPO-STATE.md).
- Worktree(s) used; confirmation that pre-existing user work was left untouched.

## Confirmed findings

One subsection per finding that reached "Confirmed and actionable":

### IF-00N: <title>

- User impact and who's affected.
- Confidence and stated proof boundaries.
- Reproduction (command + output, or a link to `findings/IF-00N-*/repro/`).
- Root cause, with file:line.
- Duplicate-screen result.
- Ranking score and the one or two criteria that drove it.
- Variant-search result.
- Draft location (`drafts/IF-00N-*.md` or `private/IF-00N-*.md`).
- Suggested next step: run `/issue-fixer IF-00N`, or "needs maintainer discussion first" for an enhancement.

## Other dispositions

A short table: ID, title, disposition, one-line why. Covers duplicates, already-fixed-upstream, needs-more-validation, and rejected hypotheses. This section is what proves the engagement wasn't just a search for yes-answers.

## Security-sensitive findings

State only that N security-sensitive findings exist and are recorded privately under `.issue-finder/private/`, with no detail in this report (which may be shared more widely than the private folder). Point to `SECURITY.md` for what happens next.

## What was and wasn't tested

Capabilities that were unavailable (from `capabilities.md`) and what that means was left unverified.

## External-action status

State separately, explicitly, for this engagement: staged / committed / pushed / rebased / force-pushed / published as an issue / submitted as a PR / disclosed privately. For a first `issue-finder` run this is almost always "none of the above"; say so rather than omitting the section.
```

If the honest result is zero confirmed findings, say that plainly in the first line of "Confirmed findings" ("No candidate reached Confirmed and actionable in this engagement.") rather than omitting the section or padding it with rejected hypotheses dressed up as findings.
