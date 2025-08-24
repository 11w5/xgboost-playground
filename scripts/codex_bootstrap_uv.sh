#!/usr/bin/env bash
set -euo pipefail

REQ_FILE="${REQ_FILE:-requirements-cpu.txt}"
VENV_DIR="${VENV_DIR:-.venv}"
UV_PY="${UV_PY:-python3}"
UV_CACHE_DIR="${UV_CACHE_DIR:-.uv_cache}"

# Install uv if missing (user-space)
if ! command -v uv >/dev/null 2>&1; then
  curl -fsSL https://astral.sh/uv/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

mkdir -p "$UV_CACHE_DIR"
export UV_CACHE_DIR="$UV_CACHE_DIR"
export UV_LINK_MODE=copy          # friendlier on overlay FS
export PIP_ONLY_BINARY=:all:
export PIP_NO_INPUT=1
export UV_PYTHON_PIP_NO_INPUT=1
export UV_HTTP_TIMEOUT="${UV_HTTP_TIMEOUT:-20}"

# Create venv & install wheels
uv venv --python "$UV_PY" "$VENV_DIR"
# shellcheck disable=SC1091
source "$VENV_DIR/bin/activate"
uv pip install --only-binary=:all: -r "$REQ_FILE"

python - <<'PY'
import sys, xgboost, numpy, scipy, pandas
print("✅ uv env ready:",
      f"py={sys.version.split()[0]}",
      f"xgb={xgboost.__version__}",
      f"np={numpy.__version__}",
      f"scipy={scipy.__version__}",
      f"pd={pandas.__version__}")
PY
echo "✅ uv cache dir: $UV_CACHE_DIR"