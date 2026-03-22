#!/usr/bin/env bash
set -e

echo "==> [01-APT-ESSENTIALS] Setting up apt and build tools..."

sudo apt update
sudo apt upgrade -y

PACKAGES=(build-essential curl git unzip zsh)
for pkg in "${PACKAGES[@]}"; do
  if dpkg -s "$pkg" &>/dev/null; then
    echo "$pkg already installed."
  else
    echo "Installing $pkg..."
    sudo apt install -y "$pkg"
  fi
done

echo "Done. Build essentials ready."
