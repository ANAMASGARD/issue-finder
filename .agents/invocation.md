# Model-invoked vs user-invoked

Every skill in this repo splits on one axis: who can reach it.

- **User-invoked** (`issue-finder`, `issue-fixer`): reachable only by a human typing its name. Frontmatter carries `disable-model-invocation: true`, and `agents/openai.yaml` carries `policy.allow_implicit_invocation: false`. The `description` stays model-readable for documentation purposes, but no harness fires the skill from it.
- **Model-invoked** (`exploratory-testing`, `verifying-findings`, `screening-duplicates`, `drafting-issues`): reachable by the human or by another skill. No `disable-model-invocation`, no `policy` block. The description carries rich trigger phrasing so a standalone question ("is this a true bug or a false positive?", "has this already been reported upstream?") can reach the right discipline without going through the full `issue-finder` pipeline.

## Why the entry points are user-invoked

A full `/issue-finder` run builds the target, exercises it like a user, and can run for a long time. Firing it from a casual "does this project have any bugs?" would surprise the user with an expensive, long-running workflow they didn't ask for. See [`.agents/adr/0001-user-invoked-entry-points.md`](adr/0001-user-invoked-entry-points.md) for the full tradeoff, including the cost: a skill with `disable-model-invocation` is a non-spec key, so it fails strict `skills-ref validate` and a claude.ai zip upload. This repo accepts that cost for `issue-finder` and `issue-fixer` only.

## Calling a companion skill

`issue-finder` calls the four model-invoked disciplines by name: "Call the Skill tool with exploratory-testing", one skill per call. This is what gets the skill reliably fired in harnesses that expose skill invocation as a callable tool, rather than leaving it to be inferred from prose. If a companion skill is not installed, the step that would have called it stops and tells the user which skill to install, naming it exactly (`exploratory-testing`, `verifying-findings`, `screening-duplicates`, or `drafting-issues`); it does not attempt to inline a weaker substitute.

A user-invoked skill can never be reached this way. `issue-fixer` is never called by `issue-finder` automatically. The pipeline's final report recommends it as something the user runs next, by name, as a separate action.
