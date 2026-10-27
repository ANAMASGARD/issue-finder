#!/usr/bin/env bash
# Scaffold the .issue-finder/ workspace inside a target checkout, and keep it
# out of that checkout's own git history.
#
# Usage: init-workspace.sh [TARGET_DIR]
#   TARGET_DIR  Path to the target git checkout. Defaults to the current directory.
#
# Non-interactive. Exits 0 on success (including "already initialized"),
# non-zero with a message on stderr on failure. Safe to re-run.
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: init-workspace.sh [TARGET_DIR]

Creates .issue-finder/{findings,drafts,private} inside TARGET_DIR (default:
current directory), sets private/ to mode 0700, and adds .issue-finder/ to
.git/info/exclude so it never becomes a tracked or staged path.

If this script cannot run in your environment, create the same layout by
hand; see skills/issue-finder/references/WORKSPACE.md for the exact tree.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

target_dir="${1:-$PWD}"

if [[ ! -d "$target_dir/.git" ]]; then
  echo "error: $target_dir does not look like a git checkout (.git not found)" >&2
  echo "       issue-finder expects to run inside a cloned target repository." >&2
  exit 1
fi

workspace="$target_dir/.issue-finder"
mkdir -p "$workspace/findings" "$workspace/drafts" "$workspace/private"
chmod 0700 "$workspace/private"

exclude_file="$target_dir/.git/info/exclude"
mkdir -p "$(dirname "$exclude_file")"
touch "$exclude_file"
if ! grep -qxF '.issue-finder/' "$exclude_file" 2>/dev/null; then
  echo '.issue-finder/' >> "$exclude_file"
fi

echo "initialized $workspace"
echo "excluded via $exclude_file"
