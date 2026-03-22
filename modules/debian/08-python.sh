#!/usr/bin/env bash
set -e

echo "==> [08-PYTHON] Setting up Python..."

if ! command -v add-apt-repository &>/dev/null; then
  echo "Installing software-properties-common..."
  sudo apt install -y software-properties-common
fi

if ! grep -rq "deadsnakes" /etc/apt/sources.list.d/ 2>/dev/null; then
  echo "Adding deadsnakes PPA..."
  sudo add-apt-repository -y ppa:deadsnakes/ppa
  sudo apt update
else
  echo "deadsnakes PPA already added."
fi

if ! dpkg -s python3.14 &>/dev/null; then
  echo "Installing python3.14..."
  sudo apt install -y python3.14 python3.14-venv python3.14-dev
else
  echo "python3.14 already installed."
fi

if ! dpkg -s python3.12 &>/dev/null; then
  echo "Installing python3.12..."
  sudo apt install -y python3.12 python3.12-venv python3.12-dev
else
  echo "python3.12 already installed."
fi

if ! command -v uv &>/dev/null; then
  echo "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
else
  echo "uv already installed."
fi

echo "Done. Python and uv ready."
