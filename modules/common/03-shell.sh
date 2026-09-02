#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> [03-SHELL] Setting up Oh My Zsh and ZSH environment..."

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh already installed."
fi

CONFIG_DIR="$SCRIPT_DIR/../../config"
CUSTOM_DIR="$HOME/.oh-my-zsh/custom"

for src in "$CONFIG_DIR"/*.zsh; do
  [ -f "$src" ] || continue
  dest="$CUSTOM_DIR/$(basename "$src")"
  if [ ! -f "$dest" ]; then
    echo "Deploying $(basename "$src") to $dest..."
    cp "$src" "$dest"
  else
    echo "$(basename "$src") already exists at $dest, skipping."
  fi
done

echo "Done. Run 'source ~/.zshrc' after setup completes."
