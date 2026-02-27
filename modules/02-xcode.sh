#!/usr/bin/env bash
set -e

echo "==> [02-XCODE] Setting up Xcode Command Line Tools..."

if xcode-select -p &>/dev/null; then
  echo "Xcode CLI tools already installed at: $(xcode-select -p)"
  exit 0
fi

echo "Launching Xcode CLI tools installer..."
xcode-select --install

echo ""
echo "A dialog box should have appeared on screen."
read -p "Press Enter once the Xcode CLI tools installation is complete..."

if xcode-select -p &>/dev/null; then
  echo "Done. Xcode CLI tools installed at: $(xcode-select -p)"
else
  echo "Warning: xcode-select -p still not returning a path. You may need to install manually." >&2
fi
