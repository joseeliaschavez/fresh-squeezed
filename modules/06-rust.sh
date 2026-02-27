#!/usr/bin/env bash
set -e

echo "==> [06-RUST] Setting up Rust..."

if ! command -v rustc &>/dev/null; then
  echo "Installing Rust via rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

source "$HOME/.cargo/env"

echo "Updating Rust stable..."
rustup update stable

if ! cargo install --list | grep -q "^tree-sitter-cli "; then
  echo "Installing tree-sitter-cli..."
  cargo install --locked tree-sitter-cli
else
  echo "tree-sitter-cli already installed."
fi

if ! cargo install --list | grep -q "^bottom "; then
  echo "Installing bottom..."
  cargo install --locked bottom
else
  echo "bottom already installed."
fi

echo "Done. Rust and cargo tools ready."
