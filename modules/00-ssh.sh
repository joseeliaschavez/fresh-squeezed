#!/usr/bin/env bash
set -e

echo "==> [00-SSH] Setting up SSH key..."

if [ -f "$HOME/.ssh/id_ed25519" ]; then
  echo "SSH key already exists at ~/.ssh/id_ed25519, skipping generation."
  echo ""
  echo "Your existing public key:"
  cat "$HOME/.ssh/id_ed25519.pub"
  exit 0
fi

read -p "Enter your email address for the SSH key: " email
if [ -z "$email" ]; then
  echo "Error: email cannot be empty." >&2
  exit 1
fi

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
ssh-keygen -t ed25519 -C "$email"

echo ""
echo "Done. Your public key (add this to GitHub at https://github.com/settings/keys):"
echo ""
cat "$HOME/.ssh/id_ed25519.pub"
