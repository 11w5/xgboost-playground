#!/usr/bin/env bash
set -euo pipefail

# ---- config knobs (tweak freely) ----
REQ_FILE="${REQ_FILE:-requirements-cpu.txt}"   # default to CPU set
VENV_DIR="${VENV_DIR:-.venv}"
UV_PY="${UV_PY:-python3}"                      # or "python3.12"
UV_CACHE_DIR="${UV_CACHE_DIR:-.uv_cache}"      # keep cache in repo workspace
# -------------------------------------

# 0) install uv (user-space) if missing
if ! command -v uv >/dev/null 2>&1; then
  echo "⬇️  Installing uv (user-space)…"
  curl -fsSL https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

# 1) make sure cache path is writable & persistent within workspace
mkdir -p "$UV_CACHE_DIR"
export UV_CACHE_DIR="$UV_CACHE_DIR"

# (Optional) faster linking on overlay filesystems
export UV_LINK_MODE=copy

# 2) create/refresh venv
uv venv --python "$UV_PY" "$VENV_DIR"

# 3) activate venv
# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"

# 4) wheel-only install, no prompts
export PIP_ONLY_BINARY=:all:
export PIP_NO_INPUT=1
export UV_PYTHON_PIP_NO_INPUT=1
export UV_HTTP_TIMEOUT="${UV_HTTP_TIMEOUT:-20}"

echo "⚡ Installing wheels from $REQ_FILE (cache: $UV_CACHE_DIR)…"
uv pip install --only-binary=:all: -r "$REQ_FILE"

# 5) sanity check
python - <<'PY'
import sys, xgboost, numpy, scipy, pandas
print("✅ uv env ready:",
      f"py={sys.version.split()[0]}",
      f"xgb={xgboost.__version__}",
      f"np={numpy.__version__}",
      f"scipy={scipy.__version__}",
      f"pd={pandas.__version__}")
PY
