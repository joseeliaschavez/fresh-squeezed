#!/usr/bin/env bash
set -e

echo "==> [07-GO] Setting up GVM and Go..."

if ! brew list bison &>/dev/null; then
  echo "Installing bison (required by GVM)..."
  brew install bison
else
  echo "bison already installed."
fi

if [ ! -s "$HOME/.gvm/scripts/gvm" ]; then
  if [ -d "$HOME/.gvm" ]; then
    echo "Found incomplete GVM install at ~/.gvm, removing before reinstalling..."
    rm -rf "$HOME/.gvm"
  fi
  echo "Installing GVM..."
  bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
else
  echo "GVM already installed."
fi

# GVM's internal functions (e.g. its cd() hook that looks for a .go-version
# file) rely on ordinary `return 1` for control flow, not fatal errors, so
# set -e must be off while sourcing it.
set +e
source "$HOME/.gvm/scripts/gvm"
set -e

GO_VERSION_FALLBACK="go1.23.4"
GO_VERSION="$(curl -fsSL --connect-timeout 5 --max-time 10 --retry 2 "https://go.dev/VERSION?m=text" 2>/dev/null | head -1)"
if [ -z "$GO_VERSION" ]; then
  echo "Warning: could not fetch latest Go version from go.dev, falling back to $GO_VERSION_FALLBACK" >&2
  GO_VERSION="$GO_VERSION_FALLBACK"
fi

if ! gvm list | grep -q "$GO_VERSION"; then
  echo "Installing $GO_VERSION (binary)..."
  gvm install "$GO_VERSION" -B
else
  echo "$GO_VERSION already installed."
fi

gvm use "$GO_VERSION" --default

echo "Done. Go $(go version) ready."
