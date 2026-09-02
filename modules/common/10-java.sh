#!/usr/bin/env bash
set -e

echo "==> [10-JAVA] Setting up SDKMAN and Java..."

# SDKMAN's installer requires Bash 4+, but macOS ships Bash 3.2 (Apple never
# upgraded past the last GPLv2 release), so install a modern Homebrew bash
# and run the installer with that explicitly.
if command -v brew &>/dev/null; then
  if ! brew list bash &>/dev/null; then
    echo "Installing modern bash (required by SDKMAN)..."
    brew install bash
  fi
  MODERN_BASH="$(brew --prefix bash)/bin/bash"
else
  MODERN_BASH="bash"
fi

if [ ! -d "$HOME/.sdkman" ]; then
  echo "Installing SDKMAN..."
  curl -s "https://get.sdkman.io" | "$MODERN_BASH"
else
  echo "SDKMAN already installed."
fi

source "$HOME/.sdkman/bin/sdkman-init.sh"

if ! sdk list java 2>/dev/null | grep -q "25.0.2-open.*installed"; then
  echo "Installing Java 25.0.2-open..."
  sdk install java 25.0.2-open
else
  echo "Java 25.0.2-open already installed."
fi

echo "Done. Java $(java --version 2>&1 | head -1) ready."
