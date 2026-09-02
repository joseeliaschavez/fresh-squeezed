#!/usr/bin/env bash
set -e

echo "==> [14-AI-TOOLS] Installing AI coding tools..."

# Claude CLI via curl (same as macOS)
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

# copilot-cli via npm
if command -v npm &>/dev/null; then
  if ! command -v copilot &>/dev/null; then
    echo "Installing copilot-cli..."
    npm install -g @github/copilot
  else
    echo "copilot-cli already installed."
  fi
else
  echo "Skipping copilot-cli (npm not available — run after 09-node)."
fi

if command -v copilot &>/dev/null; then
  echo "Installing obra/superpowers plugin for Copilot CLI..."
  copilot plugin marketplace add obra/superpowers-marketplace >/dev/null 2>&1 || true
  copilot plugin install superpowers@superpowers-marketplace >/dev/null 2>&1 || true
fi

# codex via npm
if command -v npm &>/dev/null; then
  if ! command -v codex &>/dev/null; then
    echo "Installing codex..."
    npm install -g @openai/codex
  else
    echo "codex already installed."
  fi
else
  echo "Skipping codex (npm not available — run after 09-node)."
fi

# opencode via go install
if command -v go &>/dev/null; then
  if ! command -v opencode &>/dev/null; then
    echo "Installing opencode..."
    go install github.com/opencode-ai/opencode@latest
  else
    echo "opencode already installed."
  fi
else
  echo "Skipping opencode (go not available — run after 07-go)."
fi

echo "Done. AI tools installed."
