#!/bin/sh
# fresh-squeezed installer
# https://github.com/joseeliaschavez/fresh-squeezed
#
# This script clones the fresh-squeezed repository and runs setup.sh
# to configure a complete development environment.
#
# Usage:
#   curl -sSf https://raw.githubusercontent.com/joseeliaschavez/fresh-squeezed/develop/install.sh | bash
#
# What it does:
#   1. Checks that git and curl are installed
#   2. Detects your platform (macOS or Debian-based Linux)
#   3. Clones the repo to ~/.fresh-squeezed
#   4. Runs setup.sh to install and configure dev tools
#
# You can audit this script before running it:
#   curl -sSf https://raw.githubusercontent.com/joseeliaschavez/fresh-squeezed/develop/install.sh | less

set -e

REPO_URL="https://github.com/joseeliaschavez/fresh-squeezed.git"
INSTALL_DIR="$HOME/.fresh-squeezed"
BRANCH="develop"

# --- Helpers ---

info() {
  printf '  \033[1;32m%s\033[0m %s\n' "$1" "$2"
}

warn() {
  printf '  \033[1;33m%s\033[0m %s\n' "$1" "$2"
}

error() {
  printf '  \033[1;31m%s\033[0m %s\n' "error:" "$1" >&2
}

cleanup() {
  if [ $? -ne 0 ]; then
    echo ""
    error "Installation failed. Check the output above for details."
  fi
}

trap cleanup EXIT

# --- Prerequisite checks ---

check_prerequisites() {
  local missing=0

  if ! command -v git >/dev/null 2>&1; then
    error "git is not installed."
    missing=1
  fi

  if ! command -v curl >/dev/null 2>&1; then
    error "curl is not installed."
    missing=1
  fi

  if [ "$missing" -eq 1 ]; then
    echo ""
    echo "Please install the missing tools and try again."
    case "$(uname -s)" in
      Darwin) echo "  On macOS: xcode-select --install" ;;
      Linux)  echo "  On Debian/Ubuntu: sudo apt install git curl" ;;
    esac
    exit 1
  fi
}

# --- Platform detection ---

detect_platform() {
  case "$(uname -s)" in
    Darwin) echo "darwin" ;;
    Linux)
      if [ -f /etc/debian_version ]; then
        echo "debian"
      else
        echo "unsupported"
      fi ;;
    *) echo "unsupported" ;;
  esac
}

platform_label() {
  case "$1" in
    darwin) echo "macOS" ;;
    debian) echo "Debian/Ubuntu Linux" ;;
    *)      echo "Unknown" ;;
  esac
}

# --- Main ---

main() {
  echo ""
  echo "  🍊 fresh-squeezed installer"
  echo "  No pulp, no bloat — just a freshly squeezed dev environment."
  echo ""

  check_prerequisites

  PLATFORM=$(detect_platform)
  if [ "$PLATFORM" = "unsupported" ]; then
    error "Unsupported platform. fresh-squeezed supports macOS and Debian-based Linux."
    exit 1
  fi

  PLATFORM_LABEL=$(platform_label "$PLATFORM")

  info "Platform:" "$PLATFORM_LABEL"
  info "Install to:" "$INSTALL_DIR"
  info "Branch:" "$BRANCH"
  echo ""

  # Handle existing installation
  if [ -d "$INSTALL_DIR" ]; then
    warn "warning:" "$INSTALL_DIR already exists."
    printf '  Update existing installation? [y/N] '
    read -r answer
    case "$answer" in
      [Yy]*)
        info "Updating..." "git pull"
        cd "$INSTALL_DIR"
        git pull origin "$BRANCH"
        ;;
      *)
        echo "  Aborted."
        exit 0
        ;;
    esac
  else
    printf '  Proceed with installation? [y/N] '
    read -r answer
    case "$answer" in
      [Yy]*)
        info "Cloning..." "$REPO_URL"
        git clone --branch "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
        ;;
      *)
        echo "  Aborted."
        exit 0
        ;;
    esac
  fi

  echo ""
  info "Running" "setup.sh"
  echo ""

  cd "$INSTALL_DIR"
  bash ./setup.sh

  echo ""
  echo "  🍊 fresh-squeezed installation complete!"
  echo "  Run: source ~/.zshrc"
  echo ""
}

main
