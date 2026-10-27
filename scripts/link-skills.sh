#!/usr/bin/env bash
# Symlink every skill in this repo into local agent skill directories, for
# testing changes without a real install/publish round-trip.
#
# Usage: link-skills.sh [--agent claude|codex|cursor|all] [--dry-run]
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: link-skills.sh [--agent claude|codex|cursor|all] [--dry-run]

Symlinks each skills/<name> directory in this repo into the matching local
agent skill directory, so local edits are picked up immediately without
reinstalling. Default: all.

  --agent claude   ~/.claude/skills/<name>
  --agent codex    ~/.codex/skills/<name> (also ~/.agents/skills/<name>)
  --agent cursor   ~/.cursor/skills/<name>
  --agent all      every target above (default)
  --dry-run        print what would be linked without creating anything

If this script cannot run, link each skills/<name> directory by hand into
your agent's skills directory with: ln -s <repo>/skills/<name> <target>/<name>
EOF
}

agent="all"
dry_run=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --agent) agent="$2"; shift 2 ;;
    --dry-run) dry_run=1; shift ;;
    *) echo "error: unknown argument: $1" >&2; usage >&2; exit 1 ;;
  esac
done

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skills_dir="$repo_root/skills"

targets=()
case "$agent" in
  claude) targets+=("$HOME/.claude/skills") ;;
  codex) targets+=("$HOME/.codex/skills" "$HOME/.agents/skills") ;;
  cursor) targets+=("$HOME/.cursor/skills") ;;
  all) targets+=("$HOME/.claude/skills" "$HOME/.codex/skills" "$HOME/.agents/skills" "$HOME/.cursor/skills") ;;
  *) echo "error: unknown --agent value: $agent (expected claude, codex, cursor, or all)" >&2; exit 1 ;;
esac

for target_dir in "${targets[@]}"; do
  for skill_path in "$skills_dir"/*/; do
    skill_name="$(basename "$skill_path")"
    link_path="$target_dir/$skill_name"

    if [[ $dry_run -eq 1 ]]; then
      echo "would link: $link_path -> ${skill_path%/}"
      continue
    fi

    mkdir -p "$target_dir"
    if [[ -L "$link_path" ]]; then
      rm "$link_path"
    elif [[ -e "$link_path" ]]; then
      echo "skip: $link_path already exists and is not a symlink" >&2
      continue
    fi
    ln -s "${skill_path%/}" "$link_path"
    echo "linked: $link_path -> ${skill_path%/}"
  done
done
