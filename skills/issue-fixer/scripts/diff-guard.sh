#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Copyright (C) 2026 Gaurav Chaudhary. See NOTICE for required attribution.
#
# Flag changed paths that a one-finding fix should almost never touch:
# lockfiles, secrets/env files, CI workflow config, generated output, and
# infrastructure-as-code. Flagging is not blocking; a flagged path is fine
# once you can point to the specific finding that requires it. This script
# never modifies anything, it only reports.
#
# Usage: diff-guard.sh [target_dir] [--base <ref>]
#   target_dir defaults to the current directory.
#   --base defaults to .issue-finder/sync.env's ISSUE_FINDER_BASE_SHA, if that
#   file exists; otherwise only staged, unstaged, and untracked changes are
#   checked (no branch-range diff).
#
# Exit code: 0 if nothing was flagged, 1 if something was, 2 on a usage error.
# Prints the full set of changed paths either way, flagged ones marked.
set -uo pipefail

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  cat <<'EOF'
Usage: diff-guard.sh [target_dir] [--base <ref>]

Lists every changed path (staged, unstaged, untracked, and, with a base,
everything changed since that ref) and marks the ones matching a forbidden
pattern: lockfiles, .env*, *.pem/*.key/*secret*/*credential*, generated/dist/
build/coverage output, .github/workflows/*, Dockerfiles and compose files,
and infra/ops/deploy/k8s/helm/*.tf paths.

A flagged path is not automatically wrong, it is a prompt to justify it
against the specific finding being fixed, or revert it.
EOF
  exit 0
fi

target_dir="."
base=""
while [ $# -gt 0 ]; do
  case "$1" in
    --base)
      base="${2:-}"
      shift 2
      ;;
    *)
      target_dir="$1"
      shift
      ;;
  esac
done

cd "$target_dir" || { echo "error: cannot cd to $target_dir" >&2; exit 2; }

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "error: $target_dir is not a git repository" >&2
  exit 2
fi

if [ -z "$base" ] && [ -f .issue-finder/sync.env ]; then
  base="$(grep '^ISSUE_FINDER_BASE_SHA=' .issue-finder/sync.env | cut -d= -f2-)"
fi

FORBIDDEN_PATTERNS=(
  ".env" ".env.*" "*.pem" "*.key" "*secret*" "*credential*"
  "package-lock.json" "pnpm-lock.yaml" "yarn.lock" "poetry.lock"
  "Pipfile.lock" "uv.lock" "Cargo.lock" "Gemfile.lock" "composer.lock" "go.sum"
  "dist/*" "build/*" "coverage/*" "generated/*" "__generated__/*"
  ".github/workflows/*" "Dockerfile" "docker-compose*.yml" "docker-compose*.yaml"
  "infra/*" "ops/*" "deploy/*" "k8s/*" "helm/*" "*.tf"
)

is_forbidden() {
  local path="$1" pat
  for pat in "${FORBIDDEN_PATTERNS[@]}"; do
    # shellcheck disable=SC2053
    if [[ "$path" == $pat ]]; then
      return 0
    fi
  done
  return 1
}

declare -A seen
changed=()
add_path() {
  local p="$1"
  if [ -n "$p" ] && [ -z "${seen[$p]:-}" ]; then
    seen["$p"]=1
    changed+=("$p")
  fi
}

while IFS= read -r line; do add_path "$line"; done < <(git diff --cached --name-only 2>/dev/null)
while IFS= read -r line; do add_path "$line"; done < <(git diff --name-only 2>/dev/null)
while IFS= read -r line; do
  path="${line#"?? "}"
  add_path "$path"
done < <(git status --porcelain --untracked-files=all 2>/dev/null | grep '^??')
if [ -n "$base" ]; then
  while IFS= read -r line; do add_path "$line"; done < <(git diff --name-only "${base}...HEAD" 2>/dev/null)
fi

if [ "${#changed[@]}" -eq 0 ]; then
  echo "no changed paths found"
  exit 0
fi

flagged=0
echo "Changed paths$([ -n "$base" ] && echo " (vs ${base})" || echo " (working tree only, no base diff)"):"
for path in "${changed[@]}"; do
  if is_forbidden "$path"; then
    echo "  [FLAGGED] $path"
    flagged=1
  else
    echo "  $path"
  fi
done

if [ "$flagged" -eq 1 ]; then
  echo
  echo "One or more flagged paths changed. Justify each against the finding being fixed, or revert it."
  exit 1
fi

exit 0
