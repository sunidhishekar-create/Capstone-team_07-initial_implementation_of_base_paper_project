#!/usr/bin/env bash
# One-command project setup for Linux and macOS.
# Usage (from the repo root):   bash setup.sh

set -euo pipefail
cd "$(dirname "$0")"

echo "== 1/5 Locating Python 3.10-3.12 =="
PY=""
for cand in python3.11 python3.12 python3.10 python3; do
    if command -v "$cand" >/dev/null 2>&1; then
        if "$cand" -c 'import sys; sys.exit(0 if (3,10) <= sys.version_info[:2] <= (3,12) else 1)'; then
            PY="$cand"
            break
        fi
    fi
done
if [ -z "$PY" ]; then
    echo "Python 3.10-3.12 not found."
    echo "  macOS : brew install python@3.11"
    echo "  Ubuntu: sudo apt install python3.11 python3.11-venv"
    exit 1
fi
echo "Using: $PY ($($PY --version))"

echo "== 2/5 Creating virtual environment (.venv) =="
if [ ! -d ".venv" ]; then
    "$PY" -m venv .venv || {
        echo "venv creation failed. On Ubuntu/Debian run: sudo apt install python3-venv (or python3.11-venv)"
        exit 1
    }
fi
VENV_PY=".venv/bin/python"

echo "== 3/5 Installing dependencies (PyTorch is large, be patient) =="
"$VENV_PY" -m pip install --upgrade pip
"$VENV_PY" -m pip install -r requirements.txt

echo "== 4/5 Creating project folders =="
mkdir -p configs scripts results tests \
         src/data src/models src/fl src/algorithms src/attacks src/utils
for p in src src/data src/models src/fl src/algorithms src/attacks src/utils; do
    [ -f "$p/__init__.py" ] || touch "$p/__init__.py"
done

echo "== 5/5 Verifying environment =="
"$VENV_PY" check_env.py

echo
echo "Done. Activate the environment with:  source .venv/bin/activate"
echo "In VS Code: Ctrl/Cmd+Shift+P -> 'Python: Select Interpreter' -> pick the .venv one."