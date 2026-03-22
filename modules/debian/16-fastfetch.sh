#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> [16-FASTFETCH] Setting up fastfetch..."

if [ ! -d "$HOME/.oh-my-zsh/custom" ]; then
  echo "Oh My Zsh custom dir not found at ~/.oh-my-zsh/custom. Run 03-shell.sh first." >&2
  exit 1
fi

SRC="$SCRIPT_DIR/../../config/fastfetch.zsh"
DEST="$HOME/.oh-my-zsh/custom/fastfetch.zsh"

if [ ! -f "$SRC" ]; then
  echo "Source file not found: $SRC" >&2
  exit 1
fi

if ! command -v fastfetch &>/dev/null; then
  echo "Installing fastfetch..."
  sudo apt install -y fastfetch
else
  echo "fastfetch already installed."
fi

if [ ! -f "$DEST" ]; then
  echo "Deploying fastfetch.zsh to $DEST..."
  cp "$SRC" "$DEST"
else
  echo "fastfetch.zsh already exists at $DEST, skipping."
fi

echo "Done. fastfetch will run at most once per hour on shell start."
