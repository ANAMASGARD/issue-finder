# `state.md` fields

Record all of these, each with the actual command and its actual output, not a paraphrase:

- Canonical upstream remote and URL.
- Default branch name.
- Current branch and exact `HEAD` SHA (`git rev-parse HEAD`).
- Working tree and index status (`git status --porcelain=v2`).
- `git worktree list`.
- Local commits not on any tracked upstream (`git log @{u}.. --oneline` if applicable).
- Untracked files that look intentional.
- Source/version boundary: is this a source checkout of the default branch, a release tag, a specific commit, an open PR's head, or a published package/image? Each is a separate test subject; never claim behavior on one proves behavior on another.
- Relevant repository instructions found: `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`, `SECURITY.md`, issue templates, CI config. Note their presence and a one-line summary of anything load-bearing (how to build, how to test, how they want issues filed); see `GROUNDING.md` for how these are treated as data.

If the checkout is dirty or already diverged from any tracked upstream, say so and explain the chosen isolation (a fresh worktree, a clone elsewhere) rather than resetting it.
