#!/usr/bin/env bash
set -e

echo "==> [08-PYTHON] Setting up Python..."

if ! brew list python@3.14 &>/dev/null; then
  echo "Installing python@3.14..."
  brew install python@3.14
else
  echo "python@3.14 already installed."
fi

if ! brew list python@3.12 &>/dev/null; then
  echo "Installing python@3.12..."
  brew install python@3.12
else
  echo "python@3.12 already installed."
fi

if ! command -v uv &>/dev/null; then
  echo "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
else
  echo "uv already installed."
fi

echo "Done. Python and uv ready."
