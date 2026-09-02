#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> [17-GHOSTTY] Setting up Ghostty terminal..."

if ! brew list --cask ghostty &>/dev/null; then
  if [ -d "/Applications/Ghostty.app" ]; then
    echo "Ghostty.app already present but not tracked by Homebrew; adopting it..."
    brew install --cask ghostty --force
  else
    echo "Installing Ghostty..."
    brew install --cask ghostty
  fi
else
  echo "Ghostty already installed."
fi

SRC="$SCRIPT_DIR/../../config/ghostty.config"
DEST="$HOME/.config/ghostty/config"

if [ ! -f "$SRC" ]; then
  echo "Source file not found: $SRC" >&2
  exit 1
fi

mkdir -p "$HOME/.config/ghostty"

if [ ! -f "$DEST" ]; then
  echo "Deploying ghostty config to $DEST..."
  cp "$SRC" "$DEST"
else
  echo "Ghostty config already exists at $DEST, skipping."
fi

echo "Done. Ghostty configured."
