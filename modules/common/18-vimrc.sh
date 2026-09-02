#!/usr/bin/env bash
set -e

echo "==> [18-VIMRC] Setting up amix/vimrc (The Ultimate vimrc)..."

if [ ! -d "$HOME/.vim_runtime" ]; then
  echo "Cloning amix/vimrc..."
  git clone --depth=1 https://github.com/amix/vimrc.git "$HOME/.vim_runtime"
  sh "$HOME/.vim_runtime/install_awesome_vimrc.sh"
else
  echo "amix/vimrc already installed at ~/.vim_runtime, skipping."
fi

echo "Done. Vim configured with amix/vimrc."
