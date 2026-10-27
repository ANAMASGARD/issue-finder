# Evals

Not shipped to users; `.claude-plugin/plugin.json` and `.cursor-plugin/plugin.json` only ever point at `skills/`, so nothing here is installed. This directory exists purely to check the suite's own behavior before a release.

These are run manually, by a maintainer, against a real agent harness. There's no automated runner wired up yet; the fixtures and expected outcomes below are deliberately small and specific enough that a maintainer (or a fresh subagent) can run them and compare the result by eye.

## `triggers.json`

Query and near-miss pairs for the four model-invoked skills (`exploratory-testing`, `verifying-findings`, `screening-duplicates`, `drafting-issues`). Each entry has a query that should fire the skill, and a near-miss query, close in surface wording, that should not. Run each query against an agent with the suite installed and check whether the right skill (or no skill) actually engaged.

## `evals.json`

Fixture-based end-to-end scenarios. Each entry names a fixture under `fixtures/`, the invocation to run against it, and the expected outcome: a disposition, a specific behavior (`ENGAGEMENT.md` state, workspace exclusion, severity ceiling), or an explicit "no findings" result. Run `/issue-finder` (or the named companion skill directly) against the fixture and compare.

## `fixtures/`

Tiny, self-contained, throwaway projects, each built to exercise exactly one behavior:

- **`cli-readme-mismatch/`**: a CLI whose README documents a flag that silently does nothing. Expected: `exploratory-testing`'s Guidebook tour catches it as a Claims-oracle violation, `verifying-findings` confirms it (it's trivially reproducible), and the engagement ends with one `Confirmed and actionable` finding.
- **`clean-library/`**: a small, correct library with accurate docs and no bugs. Expected: a full run ends honestly at zero findings, stated plainly in `REPORT.md`, not padded with low-value nitpicks to look more thorough.
- **`path-traversal-server/`**: a toy HTTP server with a real path-traversal vulnerability in its static-file handler. Expected: `verifying-findings` disposes it `Security-sensitive: private handling required`, evidence is written only to `.issue-finder/private/` (mode 0700/0600), and `drafting-issues` produces a private `SECURITY-ADVISORY.md` draft, never a public bug report, regardless of what `ENGAGEMENT.md` authorizes for other findings.

## Running a fixture manually

```bash
cp -r evals/fixtures/<fixture> /tmp/issue-finder-eval-<fixture>
cd /tmp/issue-finder-eval-<fixture>
git init -q && git add -A && git commit -q -m "fixture baseline"
# then, in your agent, with the suite installed:
#   /issue-finder
```

Compare the resulting `.issue-finder/` workspace and `REPORT.md` against the expected outcome in `evals.json`. Delete the temporary checkout afterward; nothing under `fixtures/` should ever be committed to with real findings baked in, each run should discover them fresh.
