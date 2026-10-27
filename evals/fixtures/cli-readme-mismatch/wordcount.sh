#!/usr/bin/env bash
# Count words in a file. See README.md for usage.
set -euo pipefail

verbose=0
file=""

for arg in "$@"; do
  case "$arg" in
    --verbose) verbose=1 ;;
    *) file="$arg" ;;
  esac
done

if [[ -z "$file" ]]; then
  echo "usage: wordcount.sh [--verbose] <file>" >&2
  exit 1
fi

total=0
while IFS= read -r line; do
  words=$(echo "$line" | wc -w)
  total=$((total + words))
done < "$file"

# BUG (planted for this fixture): --verbose is parsed above but never acted
# on. The README promises per-line counts when --verbose is set; this only
# ever prints the total, identically whether or not --verbose was passed.
echo "total: $total"
