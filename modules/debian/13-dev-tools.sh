#!/usr/bin/env bash
set -e

echo "==> [13-DEV-TOOLS] Installing developer tools..."

# Tools available via apt
APT_PACKAGES=(ripgrep)
for pkg in "${APT_PACKAGES[@]}"; do
  if dpkg -s "$pkg" &>/dev/null; then
    echo "$pkg already installed."
  else
    echo "Installing $pkg..."
    sudo apt install -y "$pkg"
  fi
done

# GitHub CLI via official apt repo
if ! command -v gh &>/dev/null; then
  echo "Installing GitHub CLI..."
  sudo mkdir -p -m 755 /etc/apt/keyrings
  if [ ! -f /etc/apt/keyrings/githubcli-archive-keyring.gpg ]; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
      sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
  fi
  sudo apt install -y gh
else
  echo "gh already installed."
fi

# lazygit via binary release
if ! command -v lazygit &>/dev/null; then
  echo "Installing lazygit..."
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
  sudo install /tmp/lazygit /usr/local/bin
  rm -f /tmp/lazygit /tmp/lazygit.tar.gz
else
  echo "lazygit already installed."
fi

# gdu via binary release
if ! command -v gdu &>/dev/null; then
  echo "Installing gdu..."
  curl -L https://github.com/dundee/gdu/releases/latest/download/gdu_linux_amd64.tgz | tar xz -C /tmp
  sudo install /tmp/gdu_linux_amd64 /usr/local/bin/gdu
  rm -f /tmp/gdu_linux_amd64
else
  echo "gdu already installed."
fi

# pnpm via npm (requires node from 09-node)
if command -v npm &>/dev/null; then
  if ! command -v pnpm &>/dev/null; then
    echo "Installing pnpm..."
    npm install -g pnpm
  else
    echo "pnpm already installed."
  fi
else
  echo "Skipping pnpm (npm not available yet — run after 09-node)."
fi

# temporal via binary release
if ! command -v temporal &>/dev/null; then
  echo "Installing temporal CLI..."
  curl -sSf https://temporal.download/cli.sh | sh
else
  echo "temporal already installed."
fi

# Sublime Text via official apt repository
if ! command -v subl &>/dev/null; then
  echo "Installing Sublime Text..."
  if [ ! -f /etc/apt/keyrings/sublimehq-pub.asc ]; then
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo tee /etc/apt/keyrings/sublimehq-pub.asc > /dev/null
  fi
  if [ ! -f /etc/apt/sources.list.d/sublime-text.sources ]; then
    echo -e 'Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/stable/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc' | sudo tee /etc/apt/sources.list.d/sublime-text.sources
    sudo apt update
  fi
  sudo apt install -y sublime-text
else
  echo "Sublime Text already installed."
fi

echo "Done. Developer tools installed."
