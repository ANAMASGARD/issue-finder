---
name: issue-fixer
description: Fix one specific confirmed finding from an issue-finder engagement, safely, with a red test first and an independent review before a PR draft. Call this explicitly, by name, for one finding at a time; it never runs implicitly and never fixes more than one finding per invocation.
license: MIT
compatibility: Needs shell, git, and the target project's own build/test toolchain. Build and run the target inside a container, VM, or disposable sandbox.
disable-model-invocation: true
---

# Issue Fixer

Fixing is not hunting. This skill starts from one finding that `verifying-findings` already disposed `Confirmed and actionable`, and ends at a PR draft, nothing more.

## Non-negotiables

1. **One finding, one run.** This skill fixes exactly one `IF-###` at a time. Don't bundle unrelated findings into one branch or one PR.
2. **Precondition: the finding's record says `Confirmed and actionable`.** If it says anything else, stop and route back to `verifying-findings` instead of fixing a hypothesis that was never confirmed.
3. **Authorization is separate from verification.** A confirmed finding does not by itself authorize creating a branch or changing source. If `ENGAGEMENT.md` doesn't already grant "local branch and source changes," ask for it explicitly before doing anything else.
4. **Never rewrite the user's history to look current.** No hard reset, no force-push, no rebase onto a fetched upstream without the specific history-rewrite authorization. Preserve the user's local branches and commits exactly as `issue-finder`'s Grounding phase recorded them.
5. **No AI-smelling branch prefixes.** Never `codex/`, `ai/`, `agent/`, or similarly generic names like `fix-bug`/`improvements`/`miscellaneous`. Use the project-native pattern in [references/BRANCHING.md](references/BRANCHING.md).
6. **Smallest fix for the traced root cause, nothing else.** No unrelated cleanup, formatting, renaming, dependency bumps, or refactors riding along in the same change.
7. **Never weaken a test to make it pass**, and never replace the real failing boundary with a mock unless the real one is genuinely unavailable in this sandbox, and that limitation is stated explicitly.
8. **Commit, push, and PR creation each need their own explicit authorization**, same as every other external action; finishing the fix doesn't imply permission to publish it.

## Preconditions

1. Read the finding's `record.md`. Confirm disposition is `Confirmed and actionable`. If it's `Security-sensitive`, this skill may still prepare a *local, unpublished* fix once that specific authorization is granted, but the PR draft step is replaced by handing the patch back for private coordination through whatever channel `drafting-issues`' security advisory named; never open a public PR for a security-sensitive fix.
2. Confirm `ENGAGEMENT.md` grants "local branch and source changes." If not, ask for it by name before proceeding.

## Steps

### 1. Safely re-sync and recheck

Before writing any code: fetch the upstream default branch, record its new SHA, and re-run the finding's minimal reproduction and a quick duplicate re-screen against that fresh commit, exactly as `verifying-findings` Gate 3 and `screening-duplicates` describe. If it no longer reproduces, stop, update the disposition to `Already fixed upstream`, and don't open a branch at all. Full procedure: [references/BRANCHING.md](references/BRANCHING.md).

### 2. Create the isolated worktree

A separate worktree, branched from the freshly fetched upstream default branch, never from a locally reset or rewritten one. Branch name follows the project-native pattern from [references/BRANCHING.md](references/BRANCHING.md), e.g. `fix/cronjob-volume-placement`, `perf/scanner-manifest-cache`, `feat/cli-risk-thresholds`.

### 3. Red: write the failing regression test first

Convert the finding's minimal reproduction into a deterministic regression test at the project's real public interface (same boundary the finding was verified at, not an internal function). Run it against the unchanged baseline and confirm it fails, for the reason you expect, not some unrelated setup error.

### 4. Green: the smallest fix for the traced root cause

Make the smallest change that corrects the root cause `verifying-findings`'s record already traced. Don't go further.

### 5. Validate

Run the full ladder in [references/VALIDATION.md](references/VALIDATION.md): the regression test, the original reproduction, affected-package tests, the full suite/lint/type-check/static checks, and — for a performance fix — a repeated controlled benchmark reporting variance, per `verifying-findings/references/PERFORMANCE-EVIDENCE.md`.

### 6. Independent review

Get a review from an installed code-review skill if one is available, or dispatch a fresh subagent with no prior context on this fix, focused on: does it actually address the traced root cause, are there missed edge cases, is the regression test strong enough to actually catch a reversion.

### 7. Write the PR draft

Local only, following [references/PR-DRAFT.md](references/PR-DRAFT.md). Opening the actual PR is a separate, explicitly authorized action.

## Stop conditions

- The finding's record isn't `Confirmed and actionable`: stop, don't fix a hypothesis.
- Required authorization is missing: ask, don't assume.
- The fresh re-check shows it's already fixed upstream: stop, update the disposition, no branch.
- The fix would require more than the smallest change to the traced root cause (suggesting the root cause wasn't actually fully traced): stop and route back to `verifying-findings` rather than pushing through a bigger, riskier change.
- A broad feature/architectural fix, rather than a targeted bug fix: stop after the evidence-backed proposal and seek maintainer alignment before writing code, same as `drafting-issues`'s `FEATURE-REQUEST.md` disposition.
