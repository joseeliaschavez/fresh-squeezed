#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load platform detection
source "$SCRIPT_DIR/lib/platform.sh"
PLATFORM=$(detect_platform)

if [ "$PLATFORM" = "unsupported" ]; then
  echo "Error: Unsupported platform. This script supports macOS and Debian-based Linux." >&2
  exit 1
fi

COMMON_DIR="$SCRIPT_DIR/modules/common"
PLATFORM_DIR="$SCRIPT_DIR/modules/$PLATFORM"

# Build sorted module list from common + platform directories
build_module_list() {
  local modules=()
  for dir in "$COMMON_DIR" "$PLATFORM_DIR"; do
    if [ -d "$dir" ]; then
      for script in "$dir"/*.sh; do
        [ -f "$script" ] && modules+=("$script")
      done
    fi
  done
  # Sort by basename (numeric prefix)
  printf '%s\n' "${modules[@]}" | awk -F/ '{print $NF, $0}' | sort | awk '{print $2}'
}

usage() {
  echo "Usage: $0 [--module <module-name>] [--list]"
  echo ""
  echo "Options:"
  echo "  --module <name>   Run a single module (e.g. --module 05-neovim)"
  echo "  --list            List all available modules"
  echo ""
  echo "Without arguments, runs all modules in order."
  echo ""
  echo "Detected platform: $PLATFORM"
}

list_modules() {
  echo "Available modules (platform: $PLATFORM):"
  while IFS= read -r script; do
    echo "  $(basename "${script%.sh}")"
  done < <(build_module_list)
}

find_module() {
  local name="$1"
  for dir in "$COMMON_DIR" "$PLATFORM_DIR"; do
    local script="$dir/${name}.sh"
    if [ -f "$script" ]; then
      echo "$script"
      return 0
    fi
  done
  return 1
}

run_module() {
  local script="$1"
  local name
  name="$(basename "${script%.sh}")"
  echo ""
  echo "========================================"
  echo "Running: $name"
  echo "========================================"
  # Re-initialize Homebrew PATH in case it was just installed by a prior module
  if [ -x "/opt/homebrew/bin/brew" ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  local code=0
  bash "$script" || code=$?
  if [ "$code" -ne 0 ]; then
    echo "" >&2
    echo "ERROR: Module '$name' failed (exit code $code). Aborting setup." >&2
    echo "Fix the issue, then resume with: $0 --module $name" >&2
    exit 1
  fi
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

echo "Platform detected: $PLATFORM"

if [ -n "$SINGLE_MODULE" ]; then
  script=$(find_module "$SINGLE_MODULE") || {
    echo "Error: Module not found: $SINGLE_MODULE (checked common/ and $PLATFORM/)" >&2
    exit 1
  }
  run_module "$script"
else
  # Read the module list from fd 3, not stdin (fd 0). Modules run via
  # `bash "$script"` inherit stdin, and any interactive prompt inside a
  # module (e.g. a `brew install --cask` confirmation) would otherwise
  # silently drain the remaining module list from this loop, causing
  # later modules to be skipped with no error.
  while IFS= read -r script <&3; do
    run_module "$script"
  done 3< <(build_module_list)
  echo ""
  echo "========================================"
  echo "Setup complete! Run: source ~/.zshrc"
  echo "========================================"
fi
