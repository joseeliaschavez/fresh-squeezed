#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> [16-FASTFETCH] Setting up fastfetch..."

if ! brew list fastfetch &>/dev/null; then
  echo "Installing fastfetch..."
  brew install fastfetch
else
  echo "fastfetch already installed."
fi

SRC="$SCRIPT_DIR/../config/fastfetch.zsh"
DEST="$HOME/.oh-my-zsh/custom/fastfetch.zsh"

if [ ! -f "$DEST" ]; then
  echo "Deploying fastfetch.zsh to $DEST..."
  cp "$SRC" "$DEST"
else
  echo "fastfetch.zsh already exists at $DEST, skipping."
fi

echo "Done. fastfetch will run at most once per hour on shell start."
