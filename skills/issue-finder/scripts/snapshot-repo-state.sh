#!/usr/bin/env bash
# Print the repo-state facts Phase 2 (Ground) needs to record, as plain text
# to stdout. Does not write any file itself; the agent copies the relevant
# facts into .issue-finder/state.md per references/REPO-STATE.md.
#
# Usage: snapshot-repo-state.sh [TARGET_DIR]
#
# Read-only: runs no command that mutates the checkout. Non-interactive.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: snapshot-repo-state.sh [TARGET_DIR]

Prints, to stdout: remotes, default branch, current branch and HEAD SHA,
working-tree/index status, worktrees, and unpushed local commits, for
TARGET_DIR (default: current directory). Entirely read-only.

If this script cannot run, gather the same facts by hand with:
  git remote -v
  git rev-parse --abbrev-ref HEAD && git rev-parse HEAD
  git status --porcelain=v2
  git worktree list
  git log @{u}.. --oneline   # only if an upstream is tracked
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

target_dir="${1:-$PWD}"
cd "$target_dir"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "error: $target_dir is not inside a git working tree" >&2
  exit 1
fi

echo "## Remotes"
git remote -v || true
echo
echo "## Current branch and HEAD"
git rev-parse --abbrev-ref HEAD
git rev-parse HEAD
echo
echo "## Working tree and index status (git status --porcelain=v2)"
git status --porcelain=v2
echo
echo "## Worktrees"
git worktree list
echo
echo "## Local commits not on upstream (if any upstream is tracked)"
git log '@{u}..' --oneline 2>/dev/null || echo "(no upstream tracked for current branch, or nothing unpushed)"
