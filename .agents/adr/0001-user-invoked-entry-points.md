# Make `issue-finder` and `issue-fixer` user-invoked, not model-invoked

`issue-finder` builds the target project, exercises it like a real user across many journeys, and can run for a long time; `issue-fixer` creates a local branch and writes source changes. Both are expensive, consequential operations.

If these carried a model-facing `description` with trigger phrasing (the normal choice for a discoverable skill), a harness could fire the full pipeline from an offhand remark like "I wonder if this repo has any bugs", surprising the user with a long-running workflow and, in `issue-fixer`'s case, a local branch and a code change they didn't explicitly ask for.

## Decision

Both entry points set `disable-model-invocation: true` in frontmatter and `policy.allow_implicit_invocation: false` in `agents/openai.yaml`. They are reachable only by a human typing `/issue-finder` or `/issue-fixer`.

The four disciplines underneath (`exploratory-testing`, `verifying-findings`, `screening-duplicates`, `drafting-issues`) stay model-invoked, because each one is useful standalone for a narrower, cheaper question ("is this a false positive?", "has this been reported?") that a harness can usefully reach for on its own.

## Cost accepted

`disable-model-invocation` is not one of the Agent Skills specification's six frontmatter keys (see `docs/research/agent-skills-format-and-distribution.md`, fact 10). A skill carrying it:

- Fails `skills-ref validate` (the reference validator) because it rejects any non-spec key.
- Fails a direct claude.ai skill zip upload for the same reason.
- Still installs and works correctly through `npx skills`, Claude Code, Cursor, Codex, and Copilot, all of which either read the key or silently ignore it without failing.

This repo accepts that cost for exactly these two skills, because the alternative (an unbounded workflow firing itself) is worse than failing a strict validator that most install paths don't run anyway.
