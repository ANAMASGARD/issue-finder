# Safe sync and branch naming

## Safely synchronizing the base

1. Recheck status, worktrees, remotes, and the canonical default branch (same facts `issue-finder/references/REPO-STATE.md` recorded at Grounding).
2. Fetch the authoritative upstream default branch.
3. Record its exact new SHA.
4. Leave the user's local default branch untouched; use the fetched remote-tracking branch as the authoritative base. In a dedicated disposable clone, a clean default branch may be fast-forwarded with `--ff-only`, but never rewritten merely to appear current.
5. Before creating a branch or changing source, rerun the minimal reproduction on the freshly fetched SHA.
6. Repeat the duplicate and current-fix screen against that SHA and current remote state.
7. If the new SHA no longer fails, disposition becomes `Already fixed upstream`; record the fixing revision when findable, and stop, no branch.
8. If it still fails, create the issue worktree directly from the freshly fetched upstream default branch.
9. Never use a hard reset to make a checkout look current.
10. For an existing issue branch, preserve local changes and commits. Rebase it onto the freshly fetched upstream default branch only when a separate history-rewrite authorization says yes. Resolve conflicts by preserving both verified intents and rerunning tests. Otherwise, leave the branch unchanged and report the required update to the user.

Example safe new-worktree pattern, adapted to the repository:

```bash
git fetch upstream <default-branch>
git worktree add -b fix/<component>-<failure> <isolated-path> upstream/<default-branch>
```

## Choosing a branch name

Pattern:

- `fix/<component>-<observable-failure>`
- `feat/<component>-<bounded-capability>`
- `perf/<component>-<measured-bottleneck>`
- `test/<component>-<missing-contract>`

Examples:

- `fix/cronjob-volume-placement`
- `fix/cli-sarif-relative-paths`
- `fix/controller-reconnect-event-loss`
- `perf/scanner-manifest-cache`
- `feat/cli-risk-thresholds`

Unless an explicit user, repository, or execution-environment rule requires a different prefix, never use:

- `codex/`
- `ai/`
- `agent/`
- `fix-bug`
- `improvements`
- `miscellaneous`
- an issue number alone, with no descriptive subject

Check whether the branch already exists locally, in another worktree, or on the remote before creating it; never overwrite one blindly.

If a higher-priority rule mandates a conflicting branch prefix (an explicit project or environment convention), follow that rule and record the reason; otherwise, use this project-native, non-AI naming policy.
