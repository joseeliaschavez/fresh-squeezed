#!/usr/bin/env bash
set -e

echo "==> [10-JAVA] Setting up SDKMAN and Java..."

if [ ! -d "$HOME/.sdkman" ]; then
  echo "Installing SDKMAN..."
  curl -s "https://get.sdkman.io" | bash
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
