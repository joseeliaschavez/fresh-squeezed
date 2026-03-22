#!/usr/bin/env bash
set -e

echo "==> [04-FONTS] Installing InconsolataGo Nerd Font Mono..."

FONT_DIR="$HOME/.fonts"
FONT_CHECK="InconsolataGo"

if fc-list | grep -qi "$FONT_CHECK"; then
  echo "InconsolataGo Nerd Font already installed."
  exit 0
fi

TMPDIR="$(mktemp -d)"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/InconsolataGo.zip"

echo "Downloading InconsolataGo Nerd Font..."
curl -L -o "$TMPDIR/InconsolataGo.zip" "$FONT_URL"

mkdir -p "$FONT_DIR"
echo "Extracting fonts to $FONT_DIR..."
unzip -o "$TMPDIR/InconsolataGo.zip" -d "$FONT_DIR"

rm -rf "$TMPDIR"

echo "Rebuilding font cache..."
fc-cache -fv

echo "Done. InconsolataGo Nerd Font Mono installed."
