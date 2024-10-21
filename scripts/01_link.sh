#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

IGNORE_PATTERN="^\.(git)"

echo "Creating dotfile links..."
for dotfile in "${PROJECT_ROOT}"/.??*; do
  dotfile_name=$(basename "${dotfile}")
  [[ ${dotfile_name} =~ $IGNORE_PATTERN ]] && continue
  target="$HOME/${dotfile_name}"

  if [ -d "${dotfile}" ]; then
    mkdir -p "$target"

    for subfile in "${dotfile}"/*; do
      subfile_name=$(basename "$subfile")
      ln -snfv "$subfile" "$target/$subfile_name"
    done
  else
    ln -snfv "${dotfile}" "$target"
  fi
done
echo "Dotfile links created."
