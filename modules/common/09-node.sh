#!/usr/bin/env bash
set -e

echo "==> [09-NODE] Setting up NVM and Node.js..."

if [ ! -d "$HOME/.nvm" ]; then
  echo "Installing NVM v0.40.4..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.4/install.sh | bash
else
  echo "NVM already installed."
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

if ! nvm ls | grep -q "v24.13.1"; then
  echo "Installing Node v24.13.1..."
  nvm install v24.13.1
else
  echo "Node v24.13.1 already installed."
fi

echo "Done. Node $(node --version) ready."
