#!/usr/bin/env bash
set -e

echo "==> [04-FONTS] Installing Nerd Fonts..."

FONT_DIR="$HOME/Library/Fonts"

# Hack Nerd Font (via Homebrew cask)
if brew list --cask font-hack-nerd-font &>/dev/null; then
  echo "font-hack-nerd-font already installed."
else
  brew install --cask font-hack-nerd-font
fi

# InconsolataGo Nerd Font (direct download — no brew cask available)
INCONSOLATA_GO_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/InconsolataGo.zip"
if ls "$FONT_DIR"/InconsolataGo*.ttf &>/dev/null 2>&1; then
  echo "InconsolataGo Nerd Font already installed."
else
  echo "Installing InconsolataGo Nerd Font..."
  TMP=$(mktemp -d)
  curl -fsSL "$INCONSOLATA_GO_URL" -o "$TMP/InconsolataGo.zip"
  unzip -q "$TMP/InconsolataGo.zip" -d "$TMP/InconsolataGo"
  cp "$TMP"/InconsolataGo/*.ttf "$FONT_DIR/"
  rm -rf "$TMP"
  echo "InconsolataGo Nerd Font installed."
fi

echo "Done. Nerd Fonts installed."
