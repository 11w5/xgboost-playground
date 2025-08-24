#!/usr/bin/env bash
set -euo pipefail
REQ_FILE="${REQ_FILE:-requirements-cpu.txt}"
WHEEL_DIR="${WHEEL_DIR:-.uv_cache/wheels}"
mkdir -p "$WHEEL_DIR"

# ensure uv exists
if ! command -v uv >/dev/null 2>&1; then
  curl -fsSL https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

# download wheels (no build) into local wheelhouse
uv pip download --only-binary=:all: -r "$REQ_FILE" -d "$WHEEL_DIR"

# optional: now install strictly from wheelhouse (offline-style)
# (must be in an active venv if you call the next line)
# uv pip install --no-index --find-links "$WHEEL_DIR" -r "$REQ_FILE"
echo "✅ Prewarmed wheels in $WHEEL_DIR"
