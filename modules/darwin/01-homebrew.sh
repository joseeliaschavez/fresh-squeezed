#!/usr/bin/env bash
set -e

echo "==> [01-HOMEBREW] Setting up Homebrew..."

if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  echo "Homebrew already installed."
fi

echo "Updating Homebrew..."
brew update

if ! brew tap | grep -q "anomalyco/tap"; then
  echo "Adding anomalyco/tap..."
  brew tap anomalyco/tap
else
  echo "anomalyco/tap already added."
fi

# Trust just the opencode formula (used by 14-ai-tools) rather than the whole
# tap, to avoid Homebrew's tap trust warning without over-broadening trust.
brew trust --formula anomalyco/tap/opencode

echo "Done. Homebrew ready."
