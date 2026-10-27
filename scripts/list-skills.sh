#!/usr/bin/env bash
# Print a one-line-per-skill summary: name, invocation mode, and description.
#
# Usage: list-skills.sh
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: list-skills.sh

Prints every skill under skills/ with its invocation mode (user-invoked or
model-invoked, read from disable-model-invocation in its SKILL.md) and its
description frontmatter field.

If this script cannot run, inspect each skills/<name>/SKILL.md's frontmatter
by hand: the name, description, and disable-model-invocation fields.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skills_dir="$repo_root/skills"

printf '%-22s %-14s %s\n' "SKILL" "INVOCATION" "DESCRIPTION"

for skill_path in "$skills_dir"/*/; do
  skill_name="$(basename "$skill_path")"
  skill_md="$skill_path/SKILL.md"

  if [[ ! -f "$skill_md" ]]; then
    printf '%-22s %-14s %s\n' "$skill_name" "unknown" "(no SKILL.md found)"
    continue
  fi

  if grep -q '^disable-model-invocation: true$' "$skill_md"; then
    invocation="user-invoked"
  else
    invocation="model-invoked"
  fi

  description="$(grep '^description:' "$skill_md" | head -n1 | sed 's/^description:[[:space:]]*//')"

  printf '%-22s %-14s %s\n' "$skill_name" "$invocation" "$description"
done
