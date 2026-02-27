#!/usr/bin/env bash
set -e

echo "==> [12-DOCKER] Setting up Docker, Colima, and docker-compose..."

if ! brew list docker &>/dev/null; then
  echo "Installing docker..."
  brew install docker
else
  echo "docker already installed."
fi

if ! brew list docker-compose &>/dev/null; then
  echo "Installing docker-compose..."
  brew install docker-compose
else
  echo "docker-compose already installed."
fi

if ! brew list colima &>/dev/null; then
  echo "Installing colima..."
  brew install colima
else
  echo "colima already installed."
fi

# Set up Docker CLI plugin symlink
mkdir -p "$HOME/.docker/cli-plugins"
if [ ! -L "$HOME/.docker/cli-plugins/docker-compose" ]; then
  echo "Linking docker-compose as Docker CLI plugin..."
  ln -sfn "$(which docker-compose)" "$HOME/.docker/cli-plugins/docker-compose"
else
  echo "docker-compose CLI plugin symlink already exists."
fi

echo "Done. Docker and Colima installed."
echo "To start Colima, run: colima start --network-address --cpu 4 --memory 8"
