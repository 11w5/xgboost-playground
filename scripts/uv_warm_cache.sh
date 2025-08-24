#!/usr/bin/env bash
set -euo pipefail

REQ_FILE="${REQ_FILE:-requirements-cpu.txt}"
UV_PY="${UV_PY:-python3}"
UV_CACHE_DIR="${UV_CACHE_DIR:-.uv_cache}"
WARM_VENV="${WARM_VENV:-.uv_warm}"

# Ensure uv exists
if ! command -v uv >/dev/null 2>&1; then
  curl -fsSL https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

mkdir -p "$UV_CACHE_DIR"
export UV_CACHE_DIR="$UV_CACHE_DIR"
export UV_LINK_MODE=copy
export PIP_ONLY_BINARY=:all:
export PIP_NO_INPUT=1
export UV_PYTHON_PIP_NO_INPUT=1
export UV_HTTP_TIMEOUT="${UV_HTTP_TIMEOUT:-20}"

# Create throwaway venv, install to populate cache
uv venv --python "$UV_PY" "$WARM_VENV"
# shellcheck disable=SC1091
source "$WARM_VENV/bin/activate"
uv pip install --only-binary=:all: -r "$REQ_FILE"

# Remove warm venv; wheels remain in UV cache
deactivate || true
rm -rf "$WARM_VENV"

echo "✅ Prewarmed UV cache at $UV_CACHE_DIR"
echo "ℹ️  Use scripts/codex_bootstrap_uv.sh to create a venv using this cache"