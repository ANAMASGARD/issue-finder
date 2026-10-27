#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
# Copyright (C) 2026 Gaurav Chaudhary. See NOTICE for required attribution.
#
# Print mechanical signals about a checkout's project type, toolchain, and
# where its CI commands are likely defined. This is a grep-based scan, not a
# real parser: it narrows where to look, it does not claim to understand the
# config files it finds. Read the files it names yourself before trusting
# any command it surfaces.
#
# Usage: detect-project.sh [target_dir]
set -uo pipefail

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  cat <<'EOF'
Usage: detect-project.sh [target_dir]

Prints, as labeled plain-text sections:
  - language/runtime marker files found (package.json, go.mod, Cargo.toml, ...)
  - likely project shape (cli, library, web-ui, http-service, mobile,
    desktop, infra, data-or-language-tool) based on marker files and layout
  - container/VM hints (Dockerfile, compose files, devcontainer.json)
  - CI workflow files found, and lines in them that look like install,
    build, lint, typecheck, or test commands
  - doc files present (README, CONTRIBUTING, CHANGELOG, docs/, examples/)

Manual fallback: read package.json "scripts", or the project's README
"Development" section, or .github/workflows/*.yml by hand.
EOF
  exit 0
fi

target_dir="${1:-.}"
cd "$target_dir" || { echo "error: cannot cd to $target_dir" >&2; exit 1; }

section() { printf '\n## %s\n' "$1"; }
have() { [ -e "$1" ]; }

section "Language and toolchain markers"
found_any=0
declare -A markers=(
  [package.json]="Node.js/JavaScript/TypeScript"
  [pyproject.toml]="Python (pyproject)"
  [setup.py]="Python (setuptools)"
  [requirements.txt]="Python (pip)"
  [Pipfile]="Python (pipenv)"
  [go.mod]="Go"
  [Cargo.toml]="Rust"
  [Gemfile]="Ruby"
  [pom.xml]="Java/Kotlin (Maven)"
  [build.gradle]="Java/Kotlin (Gradle)"
  [build.gradle.kts]="Java/Kotlin (Gradle)"
  [composer.json]="PHP"
  [mix.exs]="Elixir"
  [pubspec.yaml]="Dart/Flutter"
  [Package.swift]="Swift"
)
for marker in "${!markers[@]}"; do
  if have "$marker"; then
    echo "found: $marker -> ${markers[$marker]}"
    found_any=1
  fi
done
for csproj in ./*.csproj ./*/*.csproj; do
  [ -e "$csproj" ] && { echo "found: $csproj -> .NET"; found_any=1; }
done
[ "$found_any" -eq 0 ] && echo "none of the common language marker files were found; inspect the tree by hand"

section "Likely project shape (heuristic, confirm by reading the docs)"
shape_notes=()
if have "Dockerfile"; then
  shape_notes+=("Dockerfile present: may be a service or need containerized install")
fi
if have "docker-compose.yml" || have "docker-compose.yaml" || have "compose.yml"; then
  shape_notes+=("compose file present: likely needs sibling services (db, queue, etc.)")
fi
if have "package.json" && grep -q '"bin"' package.json 2>/dev/null; then
  shape_notes+=("package.json has a \"bin\" field: likely a CLI")
fi
if have "cmd" && [ -d "cmd" ]; then
  shape_notes+=("cmd/ directory: Go convention for CLI entrypoints")
fi
if have "bin" && [ -d "bin" ]; then
  shape_notes+=("bin/ directory: common CLI entrypoint location")
fi
for sh in ./*.sh; do
  if [ -f "$sh" ]; then
    shape_notes+=("${sh#./} at the repo root: possible CLI entrypoint, confirm from the README")
  fi
done
if have "public/index.html"; then
  shape_notes+=("public/index.html: likely a web UI")
fi
if have "next.config.js" || have "next.config.ts"; then
  shape_notes+=("Next.js config: web app, possibly full-stack")
fi
if have "vite.config.js" || have "vite.config.ts"; then
  shape_notes+=("Vite config: web UI")
fi
if have "angular.json"; then
  shape_notes+=("angular.json: web UI (Angular)")
fi
if have "android" && [ -d "android" ]; then
  shape_notes+=("android/ directory: mobile app")
fi
if have "ios" && [ -d "ios" ]; then
  shape_notes+=("ios/ directory: mobile app")
fi
tf_hit="$(find . -maxdepth 3 -name '*.tf' -type f -print -quit)"
if [ -n "$tf_hit" ]; then
  shape_notes+=("*.tf found: infrastructure-as-code")
fi
if have "Chart.yaml"; then
  shape_notes+=("Chart.yaml: Helm chart (Kubernetes infra)")
fi
if [ "${#shape_notes[@]}" -eq 0 ]; then
  echo "no strong shape signal; likely a library, or confirm from the README's own description"
else
  printf '%s\n' "${shape_notes[@]}"
fi

section "Container/VM hints"
for f in Dockerfile docker-compose.yml docker-compose.yaml compose.yml .devcontainer/devcontainer.json Vagrantfile; do
  have "$f" && echo "found: $f"
done

section "CI workflow files"
ci_files=()
[ -d .github/workflows ] && while IFS= read -r -d '' f; do ci_files+=("$f"); done < <(find .github/workflows -maxdepth 1 -type f \( -name '*.yml' -o -name '*.yaml' \) -print0 2>/dev/null)
for f in .gitlab-ci.yml .circleci/config.yml Jenkinsfile azure-pipelines.yml .travis.yml; do
  have "$f" && ci_files+=("$f")
done
if [ "${#ci_files[@]}" -eq 0 ]; then
  echo "none found; check the README's Development/Contributing section for commands instead"
else
  for f in "${ci_files[@]}"; do
    echo "--- $f ---"
    grep -nE '(^\s*-?\s*run:|^\s*run\b|npm (run|ci|test|install)|yarn |pnpm |pytest|go test|go build|go vet|cargo (test|build|clippy|fmt)|mvn |gradle|make [a-z]+|composer |bundle exec)' "$f" 2>/dev/null | head -n 20
  done
fi

section "Documentation present"
for f in README.md README.rst README.txt README CONTRIBUTING.md CONTRIBUTING.rst CHANGELOG.md HISTORY.md; do
  have "$f" && echo "found: $f"
done
have "docs" && [ -d "docs" ] && echo "found: docs/ ($(find docs -type f | wc -l) files)"
have "examples" && [ -d "examples" ] && echo "found: examples/ ($(find examples -type f | wc -l) files)"
have "SECURITY.md" && echo "found: SECURITY.md (check before any security-sensitive probing)"

exit 0
