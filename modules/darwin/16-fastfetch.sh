#!/usr/bin/env bash
set -e

echo "==> [16-FASTFETCH] Setting up fastfetch..."

if ! command -v fastfetch &>/dev/null; then
  echo "Installing fastfetch..."
  brew install fastfetch
else
  echo "fastfetch already installed."
fi

echo "Done. fastfetch will run at most once per hour on shell start."
