#!/usr/bin/env bash
set -e

echo "==> [14-AI-TOOLS] Installing AI coding tools..."

if ! command -v claude &>/dev/null; then
  echo "Installing Claude CLI..."
  curl -fsSL https://claude.ai/install.sh | bash
else
  echo "Claude CLI already installed."
fi

if ! brew list --cask copilot-cli &>/dev/null; then
  echo "Installing copilot-cli..."
  brew install --cask copilot-cli
else
  echo "copilot-cli already installed."
fi

if ! brew list --cask codex &>/dev/null; then
  echo "Installing codex..."
  brew install --cask codex
else
  echo "codex already installed."
fi

if ! brew list opencode &>/dev/null; then
  echo "Installing opencode..."
  brew install opencode
else
  echo "opencode already installed."
fi

echo "Done. AI tools installed."
