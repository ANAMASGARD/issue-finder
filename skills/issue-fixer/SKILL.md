---
name: issue-fixer
description: Fix one specific confirmed finding from an issue-finder run (an IF-### ID), red test first, smallest root-cause patch, then prove it with the project's own CI commands before writing a local PR draft. Use after issue-finder names a finding and the user picks it, or when the user directly asks to fix a specific IF-### finding. Never fixes more than one finding per run, and never starts from an unconfirmed or unscored lead.
license: GPL-3.0-only
compatibility: Needs shell, git, and the target project's own build/test toolchain. Build and run the target inside the same environment issue-finder chose for it.
---

# Issue Fixer

Fixing is not hunting. This starts from one finding `issue-finder` already scored confidence 7+ ("confirmed"), and ends at a local PR draft, nothing more.

## Non-negotiables

1. **One finding, one run.** Exactly one `IF-###` per invocation. Don't bundle unrelated findings into one branch or one PR.
2. **Precondition: the finding scored confidence 7+.** Below that, confirm with the user before touching anything; a 4-6 score means evidence alone didn't settle it.
3. **Local git operations are pre-authorized** (fetch, create the fix branch, commit on it). A dirty tree stops the run; this skill does not stash. **Push, opening a PR, opening an issue, and submitting a security report are not pre-authorized:** each needs its own explicit "yes" asked in chat at that exact point.
4. **Never rewrite the user's history.** No hard reset, no force-push, no rebase of commits that existed before this run started.
5. **No AI-smelling branch names.** Never `codex/`, `ai/`, `agent/`, `fix-bug`, `improvements`. Use the project's own style: `fix/<slug>`, `perf/<slug>`.
6. **Smallest fix for the traced root cause, nothing else.** No unrelated cleanup, formatting, renaming, or dependency bumps riding along.
7. **Never weaken a test to make it pass**, and never mock the real failing boundary unless it's genuinely unavailable here, stated explicitly if so.
8. **A security-sensitive finding never gets a public PR draft.** Prepare the patch locally if authorized, but hand it back through whatever private channel the finding's record names; nothing about it goes in a commit message or branch name.

## Steps

1. Load `.issue-finder/findings/IF-###.md` and `.issue-finder/sync.env`. If confidence is below 7, stop and confirm with the user first.
2. Refuse a dirty tree (stop and tell the user to resolve it first; this skill doesn't stash on top of `issue-finder`'s own stash). Fetch the remote from `sync.env` again and create `fix/<slug>` from the primary branch's current tip, not the possibly-stale base `issue-finder` recorded. Re-run the finding's exact reproduction here; if it no longer reproduces, stop, mark the finding "Already fixed upstream," and don't change any code.
3. **Red:** turn the reproduction into a deterministic regression test at the project's real public interface (the same boundary the finding was verified at, not an internal function). Run it against the unmodified branch and confirm it fails for the expected reason.
4. **Fix:** make the smallest change that corrects the traced root cause, in the project's existing style. Run `scripts/diff-guard.sh` and justify or revert anything it flags.
5. **Prove:** the regression test passes, and the original reproduction now shows the expected behavior, not just "doesn't crash." Then run the full ladder in `references/validation.md`, comparing every result against `issue-finder`'s recorded baseline. Allow at most 3 fix rounds; if still failing after that, stop and report `BLOCKED` with what's failing.
6. Get a pass from an installed read-only code-review skill if one is available, or a fresh subagent with no prior context, focused on: does this actually address the traced root cause, are there missed edge cases, would the regression test actually catch a reversion.
7. Make one conventional commit on the fix branch. Write the PR draft per `references/validation.md`, including the diff stat, before/after evidence, and every ladder command with PASS/FAIL and its `HEAD` SHA. Report this to the user. Never push, and never open the actual PR, unless they ask.

## Stop conditions

- Confidence below 7 and the user doesn't confirm: stop, don't fix an unsettled hypothesis.
- The tree is dirty: stop, ask the user to resolve it.
- Re-check shows it's already fixed upstream: stop, update the finding, no branch created.
- The fix needs more than the smallest change for the traced root cause (the root cause likely wasn't fully traced): stop and say so, rather than pushing through a bigger, riskier change.
- The ladder still fails after 3 rounds: stop, report `BLOCKED` with the exact failures.
- What's needed is a broad feature or architecture change, not a targeted fix: stop after describing the evidence-backed proposal; that needs the maintainer's design call, not more code from here.
