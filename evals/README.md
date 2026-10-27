# Evals

Not shipped to users; `.claude-plugin/plugin.json` and `.cursor-plugin/plugin.json` only ever point at `skills/`, so nothing here is installed. This directory exists purely to check the suite's own behavior before a release.

These are run manually, by a maintainer, against a real agent harness. There's no automated runner wired up yet; the fixtures and expected outcomes below are deliberately small and specific enough that a maintainer (or a fresh subagent) can run them and compare the result by eye.

## `triggers.json`

Query and near-miss pairs. `issue-finder` is user-invoked only: the near-miss queries must not fire it, even though they mention bugs. `issue-fixer` is model-invoked and should fire only when a specific `IF-###` ID is in play.

## `evals.json`

Fixture-based end-to-end scenarios. Each entry names a fixture under `fixtures/`, the invocation to run against it, and the expected outcome: a finding count, a confidence floor, a priority, or an explicit "no findings" result. Run `/issue-finder` against the fixture and compare.

## `fixtures/`

Tiny, self-contained, throwaway projects, each built to exercise exactly one behavior:

- **`cli-readme-mismatch/`**: a CLI whose README documents a flag that silently does nothing. Expected: hunting the documented examples catches it, confidence 7 or more, P1.
- **`clean-library/`**: a small, correct library with accurate docs and no bugs. Expected: a full run ends honestly at zero findings, stated plainly in `REPORT.md`, not padded with low-value nitpicks to look more thorough.
- **`path-traversal-server/`**: a toy HTTP server with a real path-traversal vulnerability in its static-file handler. Expected: P0 security finding, evidence written only to `.issue-finder/private/` (directory mode 0700), never a public description.

## Running a fixture manually

```bash
cp -r evals/fixtures/<fixture> /tmp/issue-finder-eval-<fixture>
cd /tmp/issue-finder-eval-<fixture>
git init -q && git add -A && git commit -q -m "fixture baseline"
# then, in your agent, with the suite installed:
#   /issue-finder
```

Compare the resulting `.issue-finder/` workspace and `REPORT.md` against the expected outcome in `evals.json`. Delete the temporary checkout afterward; nothing under `fixtures/` should ever be committed to with real findings baked in, each run should discover them fresh.
