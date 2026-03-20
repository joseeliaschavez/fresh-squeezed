#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULES_DIR="$SCRIPT_DIR/modules"

MODULES=(
  "00-ssh"
  "01-homebrew"
  "02-xcode"
  "03-shell"
  "04-fonts"
  "05-neovim"
  "06-rust"
  "07-go"
  "08-python"
  "09-node"
  "10-java"
  "11-dotnet"
  "12-docker"
  "13-dev-tools"
  "14-ai-tools"
  "15-zshrc-cleanup"
  "16-fastfetch"
)

usage() {
  echo "Usage: $0 [--module <module-name>] [--list]"
  echo ""
  echo "Options:"
  echo "  --module <name>   Run a single module (e.g. --module 05-neovim)"
  echo "  --list            List all available modules"
  echo ""
  echo "Without arguments, runs all modules in order."
}

list_modules() {
  echo "Available modules:"
  for mod in "${MODULES[@]}"; do
    echo "  $mod"
  done
}

run_module() {
  local name="$1"
  local script="$MODULES_DIR/${name}.sh"
  if [ ! -f "$script" ]; then
    echo "Error: Module not found: $script" >&2
    exit 1
  fi
  echo ""
  echo "========================================"
  echo "Running: $name"
  echo "========================================"
  bash "$script"
}

# Parse args
SINGLE_MODULE=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --module) SINGLE_MODULE="$2"; shift 2 ;;
    --list)   list_modules; exit 0 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

mkdir -p "$HOME/.local/bin"

if [ -n "$SINGLE_MODULE" ]; then
  run_module "$SINGLE_MODULE"
else
  for mod in "${MODULES[@]}"; do
    run_module "$mod"
  done
  echo ""
  echo "========================================"
  echo "Setup complete! Run: source ~/.zshrc"
  echo "========================================"
fi
