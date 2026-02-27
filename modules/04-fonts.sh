#!/usr/bin/env bash
set -e

echo "==> [04-FONTS] Installing Hack Nerd Font..."

if brew list --cask font-hack-nerd-font &>/dev/null; then
  echo "font-hack-nerd-font already installed."
else
  brew install --cask font-hack-nerd-font
fi

echo "Done. Hack Nerd Font installed."
