#!/usr/bin/env bash
set -e

echo "==> [05-NEOVIM] Setting up Neovim and AstroNvim..."

ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ]; then
  NVIM_BINARY="nvim-macos-arm64"
else
  NVIM_BINARY="nvim-macos-x86_64"
fi

mkdir -p "$HOME/.local/bin"

if [ -L "$HOME/.local/bin/nvim" ] && [ -e "$HOME/.local/bin/nvim" ]; then
  echo "Neovim symlink already exists at ~/.local/bin/nvim, skipping binary install."
else
  echo "Downloading Neovim stable ($NVIM_BINARY)..."
  TMPDIR="$HOME/tmp/nvim-install"
  mkdir -p "$TMPDIR"
  curl -L -o "$TMPDIR/${NVIM_BINARY}.tar.gz" \
    "https://github.com/neovim/neovim/releases/download/stable/${NVIM_BINARY}.tar.gz"
  xattr -c "$TMPDIR/${NVIM_BINARY}.tar.gz"
  tar xzf "$TMPDIR/${NVIM_BINARY}.tar.gz" -C "$HOME/nvim/" 2>/dev/null || \
    (mkdir -p "$HOME/nvim" && tar xzf "$TMPDIR/${NVIM_BINARY}.tar.gz" -C "$HOME/nvim/")
  rm -rf "$TMPDIR"

  if [ ! -L "$HOME/nvim/latest" ]; then
    ln -s "$HOME/nvim/$NVIM_BINARY" "$HOME/nvim/latest"
  fi
  if [ ! -L "$HOME/.local/bin/nvim" ]; then
    ln -s "$HOME/nvim/latest/bin/nvim" "$HOME/.local/bin/nvim"
  fi
  echo "Neovim installed."
fi

# AstroNvim setup
if [ -d "$HOME/.config/nvim" ]; then
  if [ ! -f "$HOME/.config/nvim/lua/plugins/astrocore.lua" ]; then
    echo "Backing up existing ~/.config/nvim to ~/.config/nvim.bak..."
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
  else
    echo "AstroNvim already configured at ~/.config/nvim, skipping."
  fi
fi

if [ ! -d "$HOME/.config/nvim" ]; then
  echo "Cloning AstroNvim template..."
  git clone --depth 1 https://github.com/AstroNvim/template "$HOME/.config/nvim"
  rm -rf "$HOME/.config/nvim/.git"
fi

echo "Done. Neovim and AstroNvim ready."
