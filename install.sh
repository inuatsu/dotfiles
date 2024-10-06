#!/bin/bash -e

IGNORE_PATTERN="^\.(git|travis)"

echo "Creating dotfile links..."
for dotfile in .??*; do
    [[ $dotfile =~ $IGNORE_PATTERN ]] && continue
    ln -snfv "$(pwd)/$dotfile" "$HOME/$dotfile"
done
echo "Dotfile links created."
