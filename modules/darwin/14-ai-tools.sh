#!/usr/bin/env bash
set -e

echo "==> [14-AI-TOOLS] Installing AI coding tools..."

if ! command -v claude &>/dev/null; then
  echo "Installing Claude CLI..."
  curl -fsSL https://claude.ai/install.sh | bash
else
  echo "Claude CLI already installed."
fi

if command -v claude &>/dev/null; then
  echo "Installing obra/superpowers plugin for Claude Code..."
  claude plugin marketplace add obra/superpowers-marketplace >/dev/null 2>&1 || true
  claude plugin install superpowers@superpowers-marketplace --scope user >/dev/null 2>&1 || true
fi

if ! brew list --cask copilot-cli &>/dev/null; then
  echo "Installing copilot-cli..."
  brew install --cask copilot-cli
else
  echo "copilot-cli already installed."
fi

if command -v copilot &>/dev/null; then
  echo "Installing obra/superpowers plugin for Copilot CLI..."
  copilot plugin marketplace add obra/superpowers-marketplace >/dev/null 2>&1 || true
  copilot plugin install superpowers@superpowers-marketplace >/dev/null 2>&1 || true
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

if ! command -v pi &>/dev/null; then
  echo "Installing Pi agent..."
  curl -fsSL https://pi.dev/install.sh | sh
else
  echo "Pi agent already installed."
fi

if command -v pi &>/dev/null; then
  echo "Installing obra/superpowers for Pi agent..."
  pi install git:github.com/obra/superpowers >/dev/null 2>&1 || true
fi

echo "Done. AI tools installed."
