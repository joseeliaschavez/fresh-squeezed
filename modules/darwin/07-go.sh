#!/usr/bin/env bash
set -e

echo "==> [07-GO] Setting up GVM and Go..."

if ! brew list bison &>/dev/null; then
  echo "Installing bison (required by GVM)..."
  brew install bison
else
  echo "bison already installed."
fi

if [ ! -d "$HOME/.gvm" ]; then
  echo "Installing GVM..."
  zsh < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
else
  echo "GVM already installed."
fi

source "$HOME/.gvm/scripts/gvm"

if ! gvm list | grep -q "go1.26.0"; then
  echo "Installing go1.26.0 (binary)..."
  gvm install go1.26.0 -B
else
  echo "go1.26.0 already installed."
fi

gvm use go1.26.0 --default

echo "Done. Go $(go version) ready."
