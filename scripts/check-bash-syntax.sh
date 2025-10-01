#!/usr/bin/env bash
set -euo pipefail

status=0

while IFS= read -r file; do
  if [[ ! -f "$file" ]]; then
    continue
  fi

  if [[ ! -r "$file" ]]; then
    echo "Skipping unreadable file: $file" >&2
    continue
  fi

  if head -n1 "$file" | grep -Eq '^#!.*\b(bash|sh)\b'; then
    if ! bash -n "$file" 2> >(sed "s|^|$file: |"); then
      status=1
    fi
  fi
done < <(git ls-files)

if [[ $status -eq 0 ]]; then
  echo "All shell scripts passed bash -n syntax check."
fi

exit $status
