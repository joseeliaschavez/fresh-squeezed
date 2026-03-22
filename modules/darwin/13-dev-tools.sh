#!/usr/bin/env bash
set -e

echo "==> [13-DEV-TOOLS] Installing developer tools..."

FORMULAE=(lazygit gdu temporal pnpm ripgrep gh)
for pkg in "${FORMULAE[@]}"; do
  if ! brew list "$pkg" &>/dev/null; then
    echo "Installing $pkg..."
    brew install "$pkg"
  else
    echo "$pkg already installed."
  fi
done

if ! brew list --cask sublime-text &>/dev/null; then
  echo "Installing Sublime Text..."
  brew install --cask sublime-text
else
  echo "Sublime Text already installed."
fi

echo "Done. Developer tools installed."
