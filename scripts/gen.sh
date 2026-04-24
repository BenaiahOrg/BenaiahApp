#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

export PATH="${HOME}/.pub-cache/bin:${PATH}"
if command -v fvm &>/dev/null; then
  FVM_BIN="fvm"
elif [[ -x "${HOME}/.pub-cache/bin/fvm" ]]; then
  FVM_BIN="${HOME}/.pub-cache/bin/fvm"
else
  echo "FVM not found. Run scripts/project_setup.sh first." >&2
  exit 1
fi

echo "Running build_runner..."
"${FVM_BIN}" dart run build_runner build --delete-conflicting-outputs

echo "Running fluttergen..."
"${FVM_BIN}" dart pub global run flutter_gen:flutter_gen_command

echo "Done."
