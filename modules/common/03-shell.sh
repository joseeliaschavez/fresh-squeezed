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

ENV_SRC="$SCRIPT_DIR/../../config/environment.zsh"
ENV_DEST="$HOME/.oh-my-zsh/custom/environment.zsh"

if [ ! -f "$ENV_DEST" ]; then
  echo "Deploying environment.zsh to $ENV_DEST..."
  cp "$ENV_SRC" "$ENV_DEST"
else
  echo "environment.zsh already exists at $ENV_DEST, skipping."
fi

echo "Done. Run 'source ~/.zshrc' after setup completes."
