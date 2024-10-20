#!/usr/bin/env bash

set -euo pipefail

IGNORE_PATTERN="^\.(git)"

echo "Creating dotfile links..."
for dotfile in .??*; do
  [[ ${dotfile} =~ $IGNORE_PATTERN ]] && continue
  target="$HOME/${dotfile}"

  if [ -d "$(pwd)/${dotfile}" ]; then
    mkdir -p "$target"

    for subfile in "$(pwd)/${dotfile}"/*; do
      subfile_name=$(basename "$subfile")
      ln -snfv "$subfile" "$target/$subfile_name"
    done
  else
    ln -snfv "$(pwd)/${dotfile}" "$target"
  fi
done
echo "Dotfile links created."
