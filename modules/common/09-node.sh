#!/usr/bin/env bash
set -e

echo "==> [09-NODE] Setting up FNM and Node.js..."

FNM_DIR="$HOME/.local/share/fnm"

if [ ! -d "$FNM_DIR" ]; then
  echo "Installing FNM..."
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
else
  echo "FNM already installed."
fi

export PATH="$FNM_DIR:$PATH"
eval "$(fnm env)"

if ! fnm list | grep -q "v24.13.1"; then
  echo "Installing Node v24.13.1..."
  fnm install v24.13.1
else
  echo "Node v24.13.1 already installed."
fi

fnm default v24.13.1

echo "Done. Node $(node --version) ready."
