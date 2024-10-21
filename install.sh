#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"

echo "Executing scripts in $SCRIPTS_DIR..."

for script in $(find "$SCRIPTS_DIR" -type f -name '*.sh' | sort); do
  echo "Running $script..."
  bash "$script"
done

echo "All scripts executed."
