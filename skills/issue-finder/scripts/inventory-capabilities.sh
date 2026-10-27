#!/usr/bin/env bash
# Print a best-effort inventory of locally available toolchains and sandboxes,
# as plain text to stdout, for Phase 2 (Ground). Never installs anything.
#
# Usage: inventory-capabilities.sh
#
# Every check is wrapped so a missing tool prints "not found" instead of
# aborting the script; the agent records each "not found" as a stated
# capability boundary per references/CAPABILITIES.md, not a silent gap.
set -uo pipefail

usage() {
  cat <<'EOF'
Usage: inventory-capabilities.sh

Prints, to stdout, versions of common language toolchains, container
runtimes, and network reachability, with "not found" for anything missing.
Installs nothing and makes no outbound network call beyond one DNS/HTTP
reachability probe (skippable; see output).

If this script cannot run, check manually: node --version, python3 --version,
go version, docker info / podman info, and whether your package manager can
reach its registry.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

probe() {
  local label="$1"; shift
  local out
  if out="$("$@" 2>&1)"; then
    printf '%-22s %s\n' "$label" "$(echo "$out" | head -n1)"
  else
    printf '%-22s not found\n' "$label"
  fi
}

echo "## Language toolchains"
probe "node"    node --version
probe "python3" python3 --version
probe "go"      go version
probe "ruby"    ruby --version
probe "java"    java -version
probe "rustc"   rustc --version
probe "php"     php --version

echo
echo "## Containers and sandboxing"
probe "docker"  docker --version
probe "podman"  podman --version

echo
echo "## Network reachability (best-effort, 3s timeout)"
if command -v curl >/dev/null 2>&1; then
  if curl -fsS --max-time 3 -o /dev/null https://registry.npmjs.org/ 2>/dev/null; then
    echo "outbound https          reachable (registry.npmjs.org)"
  else
    echo "outbound https          not reachable or blocked within 3s"
  fi
else
  echo "outbound https          curl not found, skipped"
fi
