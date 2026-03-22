#!/usr/bin/env bash
set -e

echo "==> [11-DOTNET] Setting up .NET SDK..."

if [ -f "$HOME/.dotnet/dotnet" ]; then
  echo ".NET already installed at ~/.dotnet/dotnet"
  exit 0
fi

mkdir -p "$HOME/tmp"

echo "Downloading dotnet-install.sh..."
curl -o "$HOME/tmp/dotnet-install.sh" https://dot.net/v1/dotnet-install.sh
chmod +x "$HOME/tmp/dotnet-install.sh"

echo "Running dotnet-install.sh..."
"$HOME/tmp/dotnet-install.sh"

rm "$HOME/tmp/dotnet-install.sh"

echo "Done. .NET installed to ~/.dotnet"
