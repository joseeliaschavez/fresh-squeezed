#!/usr/bin/env bash
set -e

source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/select-agents.sh"
source "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/lib/platform.sh"

# Prompt only if setup.sh hasn't already (e.g. --module 14-ai-tools)
select_ai_agents "$(detect_platform)"

echo "==> [14-AI-TOOLS] Installing AI coding tools (selected: $FS_AI_AGENTS)..."

if ai_agent_selected claude; then
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
fi

if ai_agent_selected copilot; then
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
fi

if ai_agent_selected codex; then
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
fi

if ai_agent_selected opencode; then
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
fi

# Agent document tooling (conversion + OCR)
if ai_any_agent_selected; then
  for pkg in pandoc poppler-utils ocrmypdf; do
    if ! dpkg -s "$pkg" &>/dev/null; then
      echo "Installing $pkg..."
      sudo apt install -y "$pkg"
    else
      echo "$pkg already installed."
    fi
  done

  if command -v uv &>/dev/null; then
    for spec in "markitdown[all]:markitdown" "marker-pdf:marker_single" "docling:docling"; do
      pkg="${spec%%:*}"; bin="${spec##*:}"
      if ! command -v "$bin" &>/dev/null; then
        echo "Installing $pkg..."
        uv tool install "$pkg"
      else
        echo "$pkg already installed."
      fi
    done
  else
    echo "Skipping uv tools (uv not available — run after 08-python)."
  fi
fi

echo "Done. AI tools installed."
