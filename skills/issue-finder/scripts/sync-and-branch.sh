#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Copyright (C) 2026 Gaurav Chaudhary. See NOTICE for required attribution.
#
# Sync the target checkout's primary branch to its latest upstream commit,
# then branch off into a fresh bughunt/ branch, without ever moving the
# user's original branch pointer, dropping a stash, or rewriting history.
#
# What it does, in order:
#   1. Refuses to run if a merge/rebase/cherry-pick/revert/bisect is already
#      in progress. Nothing is touched; fix that first.
#   2. Creates .issue-finder/{findings,drafts,private} (private/ at mode
#      0700) and adds .issue-finder/ to .git/info/exclude.
#   3. If the working tree is dirty, stashes it (tracked + untracked) and
#      records the stash ref. A stash is created here but never dropped by
#      this script.
#   4. Picks a remote: upstream > origin > the first remote `git remote`
#      lists. With no remote at all, skips sync (status=no_remote) but still
#      isolates the work into a bughunt branch off the current HEAD.
#   5. Picks the primary branch: the remote's HEAD symref if set, else the
#      first of main/master/develop/trunk that exists on that remote.
#   6. If the primary branch is checked out in a different worktree, stops
#      without mutating anything (status=primary_checked_out_elsewhere) and
#      names that worktree's path.
#   7. Fetches, switches to the primary branch (creating a local tracking
#      branch if needed), and rebases it onto the freshly fetched remote
#      ref. Fast-forwards when there are no local commits; replays them
#      otherwise. On conflict: aborts the rebase, switches back to the
#      branch the user started on, keeps the stash, and stops
#      (status=rebase_conflict).
#   8. Updates submodules if the checkout has any.
#   9. Creates bughunt/<YYYY-MM-DD>-<short-sha> off the synced primary
#      branch and switches to it.
#  10. Writes .issue-finder/sync.env (read later by issue-fixer) and prints
#      a status line plus a restore hint.
#
# Usage: sync-and-branch.sh [target_dir]
#   target_dir defaults to the current directory.
#
# This script does not use `set -e`: a mid-rebase conflict is an expected
# outcome it handles explicitly, not a bug. Read the printed status= line;
# the exit code is always 0 once argument parsing succeeds.
set -uo pipefail

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  cat <<'EOF'
Usage: sync-and-branch.sh [target_dir]

Syncs target_dir's primary branch (main/master/develop/trunk, or whatever
the remote's HEAD points at) to its latest upstream commit, stashing any
local changes first, then creates and switches to a new bughunt/<date>-<sha>
branch. Never drops a stash, never force-pushes, never touches the user's
original branch pointer.

Prints one of:
  status=ok                            sync and branch succeeded
  status=in_progress_operation         a merge/rebase/etc. is already running
  status=no_remote                     no remote configured; branch created off current HEAD
  status=primary_checked_out_elsewhere another worktree already has it checked out
  status=rebase_conflict               rebase hit a conflict; aborted and restored
  status=stash_failed                  dirty tree, but stash push failed; nothing else was touched
  status=switch_failed                 could not check out the primary or hunt branch; stopped

Creates .issue-finder/{findings,drafts,private} (private/ at mode 0700) and
writes .issue-finder/sync.env with the facts issue-fixer needs later.

Manual fallback if this script can't run: `git stash -u`, `git fetch <remote>`,
`git switch <primary>`, `git rebase <remote>/<primary>`, then
`git switch -c bughunt/$(date +%F)-$(git rev-parse --short HEAD)`.
EOF
  exit 0
fi

target_dir="${1:-.}"
cd "$target_dir" || { echo "error: cannot cd to $target_dir" >&2; exit 1; }

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "error: $target_dir is not a git repository" >&2
  exit 1
fi

git_path() { git rev-parse --git-path "$1" 2>/dev/null; }

for marker in MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD rebase-merge rebase-apply BISECT_LOG; do
  path="$(git_path "$marker")"
  if [ -n "$path" ] && [ -e "$path" ]; then
    echo "status=in_progress_operation"
    echo "detail=$marker present at $path; resolve or abort it first"
    exit 0
  fi
done

mkdir -p .issue-finder/findings .issue-finder/drafts
mkdir -p .issue-finder/private
chmod 0700 .issue-finder/private 2>/dev/null || true
exclude_file="$(git rev-parse --git-path info/exclude)"
mkdir -p "$(dirname "$exclude_file")"
if [ ! -f "$exclude_file" ] || ! grep -qx '.issue-finder/' "$exclude_file" 2>/dev/null; then
  echo '.issue-finder/' >>"$exclude_file"
fi

original_branch="$(git rev-parse --abbrev-ref HEAD)"
stash_ref="none"
if [ -n "$(git status --porcelain)" ]; then
  stash_label="issue-finder auto-stash $(date -u +%FT%TZ) from ${original_branch}"
  if git stash push --include-untracked -m "$stash_label" >/dev/null 2>&1; then
    stash_ref="stash@{0}: ${stash_label}"
  else
    echo "status=stash_failed"
    echo "detail=working tree is dirty but git stash push --include-untracked failed; nothing else was touched"
    exit 0
  fi
fi

remote=""
for candidate in upstream origin; do
  if git remote get-url "$candidate" >/dev/null 2>&1; then
    remote="$candidate"
    break
  fi
done
if [ -z "$remote" ]; then
  remote="$(git remote | head -n1)"
fi

stop_switch() {
  echo "status=switch_failed"
  echo "detail=$*"
  echo "stash=${stash_ref}"
  [ "$stash_ref" != "none" ] && echo "restore_hint=git switch ${original_branch} && git stash list  # then git stash apply the one named above"
  exit 0
}

if [ -z "$remote" ]; then
  sha="$(git rev-parse --short HEAD)"
  hunt_branch="bughunt/$(date -u +%F)-${sha}"
  if git show-ref --verify --quiet "refs/heads/${hunt_branch}"; then
    hunt_branch="${hunt_branch}-$(date -u +%H%M%S)"
  fi
  if ! git switch -c "$hunt_branch" >/dev/null 2>&1; then
    stop_switch "could not create ${hunt_branch}"
  fi
  {
    echo "ISSUE_FINDER_STATUS=no_remote"
    echo "ISSUE_FINDER_REMOTE="
    echo "ISSUE_FINDER_PRIMARY_BRANCH=${original_branch}"
    echo "ISSUE_FINDER_BASE_SHA=${sha}"
    echo "ISSUE_FINDER_HUNT_BRANCH=${hunt_branch}"
    echo "ISSUE_FINDER_ORIGINAL_BRANCH=${original_branch}"
    echo "ISSUE_FINDER_STASH_REF=${stash_ref}"
  } >.issue-finder/sync.env
  echo "status=no_remote"
  echo "detail=no git remote configured; hunting from current HEAD on ${hunt_branch}, nothing synced"
  echo "stash=${stash_ref}"
  [ "$stash_ref" != "none" ] && echo "restore_hint=git switch ${original_branch} && git stash list  # then git stash apply the one named above"
  exit 0
fi

fetch_ok=1
if ! git fetch "$remote" --prune >/dev/null 2>&1; then
  fetch_ok=0
fi

primary=""
symref="$(git symbolic-ref --quiet --short "refs/remotes/${remote}/HEAD" 2>/dev/null || true)"
if [ -n "$symref" ]; then
  primary="${symref#"${remote}"/}"
else
  for candidate in main master develop trunk; do
    if git show-ref --verify --quiet "refs/remotes/${remote}/${candidate}"; then
      primary="$candidate"
      break
    fi
  done
fi
if [ -z "$primary" ]; then
  primary="$original_branch"
fi

other_worktree="$(git worktree list --porcelain | awk -v b="refs/heads/${primary}" '
  /^worktree /{wt=$2} /^branch /{if ($2==b) print wt}')"
current_worktree_path="$(git rev-parse --show-toplevel)"
if [ -n "$other_worktree" ] && [ "$other_worktree" != "$current_worktree_path" ]; then
  echo "status=primary_checked_out_elsewhere"
  echo "detail=${primary} is already checked out at ${other_worktree}"
  echo "stash=${stash_ref}"
  [ "$stash_ref" != "none" ] && echo "restore_hint=git switch ${original_branch} && git stash list  # then git stash apply the one named above"
  exit 0
fi

if git show-ref --verify --quiet "refs/heads/${primary}"; then
  if ! git switch "$primary" >/dev/null 2>&1; then
    stop_switch "could not switch to existing local branch ${primary}"
  fi
else
  if ! git switch -c "$primary" --track "${remote}/${primary}" >/dev/null 2>&1; then
    stop_switch "could not create local ${primary} tracking ${remote}/${primary}"
  fi
fi

rebase_ok=1
if git show-ref --verify --quiet "refs/remotes/${remote}/${primary}"; then
  if ! git rebase "${remote}/${primary}" >/dev/null 2>&1; then
    rebase_ok=0
  fi
fi

if [ "$rebase_ok" -eq 0 ]; then
  git rebase --abort >/dev/null 2>&1
  git switch "$original_branch" >/dev/null 2>&1
  echo "status=rebase_conflict"
  echo "detail=rebasing ${primary} onto ${remote}/${primary} conflicted; aborted and returned to ${original_branch}"
  echo "stash=${stash_ref}"
  [ "$stash_ref" != "none" ] && echo "restore_hint=you are back on ${original_branch}; stash is intact, nothing was lost"
  exit 0
fi

if [ -f .gitmodules ]; then
  git submodule update --init --recursive >/dev/null 2>&1
fi

base_sha="$(git rev-parse HEAD)"
short_sha="$(git rev-parse --short HEAD)"
hunt_branch="bughunt/$(date -u +%F)-${short_sha}"
if git show-ref --verify --quiet "refs/heads/${hunt_branch}"; then
  hunt_branch="${hunt_branch}-$(date -u +%H%M%S)"
fi
if ! git switch -c "$hunt_branch" >/dev/null 2>&1; then
  stop_switch "could not create ${hunt_branch} from ${primary}"
fi

{
  echo "ISSUE_FINDER_STATUS=ok"
  echo "ISSUE_FINDER_REMOTE=${remote}"
  echo "ISSUE_FINDER_PRIMARY_BRANCH=${primary}"
  echo "ISSUE_FINDER_BASE_SHA=${base_sha}"
  echo "ISSUE_FINDER_HUNT_BRANCH=${hunt_branch}"
  echo "ISSUE_FINDER_ORIGINAL_BRANCH=${original_branch}"
  echo "ISSUE_FINDER_STASH_REF=${stash_ref}"
} >.issue-finder/sync.env

echo "status=ok"
echo "remote=${remote}"
echo "primary_branch=${primary}"
echo "base_sha=${base_sha}"
echo "hunt_branch=${hunt_branch}"
echo "original_branch=${original_branch}"
echo "stash=${stash_ref}"
[ "$fetch_ok" -eq 0 ] && echo "warning=git fetch ${remote} failed; used existing remote refs"
[ "$stash_ref" != "none" ] && echo "restore_hint=git switch ${original_branch} && git stash list  # then git stash apply the one named above"
exit 0
