# Cross-Platform (macOS + Debian) Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Refactor setup scripts to support both macOS (Homebrew) and Debian (apt) via platform-specific module directories.

**Architecture:** Split modules into `modules/common/` (OS-agnostic, unchanged), `modules/darwin/` (current macOS modules), and `modules/debian/` (new Debian equivalents). A `lib/platform.sh` helper detects the OS. `setup.sh` merges modules from `common/` + platform dir, sorts by numeric prefix, and runs them in order.

**Tech Stack:** Bash, apt, Homebrew, curl

**Design doc:** `docs/plans/2026-03-21-cross-platform-design.md`

---

### Task 1: Create lib/platform.sh

**Files:**
- Create: `lib/platform.sh`

**Step 1: Create the platform detection helper**

```bash
#!/usr/bin/env bash
# Platform detection helper — sourced by setup.sh

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
```

**Step 2: Verify syntax**

Run: `bash -n lib/platform.sh`
Expected: no output (clean parse)

**Step 3: Commit**

```bash
git add lib/platform.sh
git commit -m "feat: add platform detection helper (lib/platform.sh)"
```

---

### Task 2: Refactor setup.sh

**Files:**
- Modify: `setup.sh`

**Step 1: Rewrite setup.sh to use platform detection and directory-based module discovery**

Replace the entire file with:

```bash
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
  printf '%s\n' "${modules[@]}" | sort -t/ -k"$(echo "${modules[0]}" | tr '/' '\n' | wc -l)" | while read -r path; do
    echo "$path"
  done
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
  bash "$script"
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
  while IFS= read -r script; do
    run_module "$script"
  done < <(build_module_list)
  echo ""
  echo "========================================"
  echo "Setup complete! Run: source ~/.zshrc"
  echo "========================================"
fi
```

**Step 2: Verify syntax**

Run: `bash -n setup.sh`
Expected: no output (clean parse)

**Step 3: Commit**

```bash
git add setup.sh
git commit -m "refactor: setup.sh uses platform detection and directory-based module discovery"
```

---

### Task 3: Move OS-agnostic modules to modules/common/

**Files:**
- Move: `modules/00-ssh.sh` → `modules/common/00-ssh.sh`
- Move: `modules/03-shell.sh` → `modules/common/03-shell.sh`
- Move: `modules/06-rust.sh` → `modules/common/06-rust.sh`
- Move: `modules/09-node.sh` → `modules/common/09-node.sh`
- Move: `modules/10-java.sh` → `modules/common/10-java.sh`
- Move: `modules/11-dotnet.sh` → `modules/common/11-dotnet.sh`
- Move: `modules/15-zshrc-cleanup.sh` → `modules/common/15-zshrc-cleanup.sh`

**Step 1: Create directory and move files**

```bash
mkdir -p modules/common
git mv modules/00-ssh.sh modules/common/
git mv modules/03-shell.sh modules/common/
git mv modules/06-rust.sh modules/common/
git mv modules/09-node.sh modules/common/
git mv modules/10-java.sh modules/common/
git mv modules/11-dotnet.sh modules/common/
git mv modules/15-zshrc-cleanup.sh modules/common/
```

**Step 2: Verify the config path in 03-shell.sh still resolves**

The script uses `$SCRIPT_DIR/../config/environment.zsh`. After the move, `SCRIPT_DIR` will be `modules/common/`, so `../config/` becomes `modules/config/` which is wrong. Fix the path to use `../../config/`:

In `modules/common/03-shell.sh`, change:
```bash
ENV_SRC="$SCRIPT_DIR/../config/environment.zsh"
```
to:
```bash
ENV_SRC="$SCRIPT_DIR/../../config/environment.zsh"
```

**Step 3: Apply the same path fix to modules/common/15-zshrc-cleanup.sh if needed**

Check: `15-zshrc-cleanup.sh` does NOT reference `$SCRIPT_DIR/../config/`, so no change needed.

**Step 4: Commit**

```bash
git add modules/common/
git commit -m "refactor: move OS-agnostic modules to modules/common/"
```

---

### Task 4: Move macOS modules to modules/darwin/

**Files:**
- Move: `modules/01-homebrew.sh` → `modules/darwin/01-homebrew.sh`
- Move: `modules/02-xcode.sh` → `modules/darwin/02-xcode.sh`
- Move: `modules/04-fonts.sh` → `modules/darwin/04-fonts.sh`
- Move: `modules/05-neovim.sh` → `modules/darwin/05-neovim.sh`
- Move: `modules/07-go.sh` → `modules/darwin/07-go.sh`
- Move: `modules/08-python.sh` → `modules/darwin/08-python.sh`
- Move: `modules/12-docker.sh` → `modules/darwin/12-docker.sh`
- Move: `modules/13-dev-tools.sh` → `modules/darwin/13-dev-tools.sh`
- Move: `modules/14-ai-tools.sh` → `modules/darwin/14-ai-tools.sh`
- Move: `modules/16-fastfetch.sh` → `modules/darwin/16-fastfetch.sh`

**Step 1: Create directory and move files**

```bash
mkdir -p modules/darwin
git mv modules/01-homebrew.sh modules/darwin/
git mv modules/02-xcode.sh modules/darwin/
git mv modules/04-fonts.sh modules/darwin/
git mv modules/05-neovim.sh modules/darwin/
git mv modules/07-go.sh modules/darwin/
git mv modules/08-python.sh modules/darwin/
git mv modules/12-docker.sh modules/darwin/
git mv modules/13-dev-tools.sh modules/darwin/
git mv modules/14-ai-tools.sh modules/darwin/
git mv modules/16-fastfetch.sh modules/darwin/
```

**Step 2: Fix config path in modules/darwin/16-fastfetch.sh**

Change:
```bash
SRC="$SCRIPT_DIR/../config/fastfetch.zsh"
```
to:
```bash
SRC="$SCRIPT_DIR/../../config/fastfetch.zsh"
```

**Step 3: Verify modules/ top-level directory is now empty of .sh files**

Run: `ls modules/*.sh 2>/dev/null && echo "ERROR: orphan scripts remain" || echo "OK: modules/ clean"`
Expected: `OK: modules/ clean`

**Step 4: Commit**

```bash
git add modules/darwin/
git commit -m "refactor: move macOS-specific modules to modules/darwin/"
```

---

### Task 5: Create modules/debian/01-apt-essentials.sh

**Files:**
- Create: `modules/debian/01-apt-essentials.sh`

**Step 1: Create the module**

```bash
#!/usr/bin/env bash
set -e

echo "==> [01-APT-ESSENTIALS] Setting up apt and build tools..."

sudo apt update
sudo apt upgrade -y

PACKAGES=(build-essential curl git unzip zsh)
for pkg in "${PACKAGES[@]}"; do
  if dpkg -s "$pkg" &>/dev/null; then
    echo "$pkg already installed."
  else
    echo "Installing $pkg..."
    sudo apt install -y "$pkg"
  fi
done

echo "Done. Build essentials ready."
```

**Step 2: Verify syntax**

Run: `bash -n modules/debian/01-apt-essentials.sh`
Expected: no output

**Step 3: Commit**

```bash
git add modules/debian/01-apt-essentials.sh
git commit -m "feat: add Debian module 01-apt-essentials"
```

---

### Task 6: Create modules/debian/04-fonts.sh

**Files:**
- Create: `modules/debian/04-fonts.sh`

**Step 1: Create the module**

```bash
#!/usr/bin/env bash
set -e

echo "==> [04-FONTS] Installing InconsolataGo Nerd Font Mono..."

FONT_DIR="$HOME/.fonts"
FONT_CHECK="InconsolataGo"

if fc-list | grep -qi "$FONT_CHECK"; then
  echo "InconsolataGo Nerd Font already installed."
  exit 0
fi

TMPDIR="$(mktemp -d)"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/InconsolataGo.zip"

echo "Downloading InconsolataGo Nerd Font..."
curl -L -o "$TMPDIR/InconsolataGo.zip" "$FONT_URL"

mkdir -p "$FONT_DIR"
echo "Extracting fonts to $FONT_DIR..."
unzip -o "$TMPDIR/InconsolataGo.zip" -d "$FONT_DIR"

rm -rf "$TMPDIR"

echo "Rebuilding font cache..."
fc-cache -fv

echo "Done. InconsolataGo Nerd Font Mono installed."
```

**Step 2: Verify syntax**

Run: `bash -n modules/debian/04-fonts.sh`
Expected: no output

**Step 3: Commit**

```bash
git add modules/debian/04-fonts.sh
git commit -m "feat: add Debian module 04-fonts (InconsolataGo Nerd Font)"
```

---

### Task 7: Create modules/debian/05-neovim.sh

**Files:**
- Create: `modules/debian/05-neovim.sh`

**Step 1: Create the module**

```bash
#!/usr/bin/env bash
set -e

echo "==> [05-NEOVIM] Setting up Neovim and AstroNvim..."

ARCH=$(uname -m)
if [ "$ARCH" = "aarch64" ]; then
  NVIM_BINARY="nvim-linux-arm64"
else
  NVIM_BINARY="nvim-linux-x86_64"
fi

mkdir -p "$HOME/.local/bin"

if [ -L "$HOME/.local/bin/nvim" ] && [ -e "$HOME/.local/bin/nvim" ]; then
  echo "Neovim symlink already exists at ~/.local/bin/nvim, skipping binary install."
else
  echo "Downloading Neovim stable ($NVIM_BINARY)..."
  TMPDIR="$(mktemp -d)"
  curl -L -o "$TMPDIR/${NVIM_BINARY}.tar.gz" \
    "https://github.com/neovim/neovim/releases/download/stable/${NVIM_BINARY}.tar.gz"
  mkdir -p "$HOME/nvim"
  tar xzf "$TMPDIR/${NVIM_BINARY}.tar.gz" -C "$HOME/nvim/"
  rm -rf "$TMPDIR"

  if [ ! -L "$HOME/nvim/latest" ]; then
    ln -s "$HOME/nvim/$NVIM_BINARY" "$HOME/nvim/latest"
  fi
  if [ ! -L "$HOME/.local/bin/nvim" ]; then
    ln -s "$HOME/nvim/latest/bin/nvim" "$HOME/.local/bin/nvim"
  fi
  echo "Neovim installed."
fi

# AstroNvim setup
if [ -d "$HOME/.config/nvim" ]; then
  if [ ! -f "$HOME/.config/nvim/lua/plugins/astrocore.lua" ]; then
    echo "Backing up existing ~/.config/nvim to ~/.config/nvim.bak..."
    mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
  else
    echo "AstroNvim already configured at ~/.config/nvim, skipping."
  fi
fi

if [ ! -d "$HOME/.config/nvim" ]; then
  echo "Cloning AstroNvim template..."
  git clone --depth 1 https://github.com/AstroNvim/template "$HOME/.config/nvim"
  rm -rf "$HOME/.config/nvim/.git"
fi

echo "Done. Neovim and AstroNvim ready."
```

**Step 2: Verify syntax**

Run: `bash -n modules/debian/05-neovim.sh`
Expected: no output

**Step 3: Commit**

```bash
git add modules/debian/05-neovim.sh
git commit -m "feat: add Debian module 05-neovim (Linux binary + AstroNvim)"
```

---

### Task 8: Create modules/debian/07-go.sh

**Files:**
- Create: `modules/debian/07-go.sh`

**Step 1: Create the module**

```bash
#!/usr/bin/env bash
set -e

echo "==> [07-GO] Setting up GVM and Go..."

if ! dpkg -s bison &>/dev/null; then
  echo "Installing bison (required by GVM)..."
  sudo apt install -y bison
else
  echo "bison already installed."
fi

if [ ! -d "$HOME/.gvm" ]; then
  echo "Installing GVM..."
  zsh < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
else
  echo "GVM already installed."
fi

source "$HOME/.gvm/scripts/gvm"

if ! gvm list | grep -q "go1.26.0"; then
  echo "Installing go1.26.0 (binary)..."
  gvm install go1.26.0 -B
else
  echo "go1.26.0 already installed."
fi

gvm use go1.26.0 --default

echo "Done. Go $(go version) ready."
```

**Step 2: Verify syntax**

Run: `bash -n modules/debian/07-go.sh`
Expected: no output

**Step 3: Commit**

```bash
git add modules/debian/07-go.sh
git commit -m "feat: add Debian module 07-go (apt bison + GVM)"
```

---

### Task 9: Create modules/debian/08-python.sh

**Files:**
- Create: `modules/debian/08-python.sh`

**Step 1: Create the module**

```bash
#!/usr/bin/env bash
set -e

echo "==> [08-PYTHON] Setting up Python..."

if ! command -v add-apt-repository &>/dev/null; then
  echo "Installing software-properties-common..."
  sudo apt install -y software-properties-common
fi

if ! grep -q "deadsnakes" /etc/apt/sources.list.d/* 2>/dev/null; then
  echo "Adding deadsnakes PPA..."
  sudo add-apt-repository -y ppa:deadsnakes/ppa
  sudo apt update
else
  echo "deadsnakes PPA already added."
fi

if ! dpkg -s python3.14 &>/dev/null; then
  echo "Installing python3.14..."
  sudo apt install -y python3.14 python3.14-venv python3.14-dev
else
  echo "python3.14 already installed."
fi

if ! dpkg -s python3.12 &>/dev/null; then
  echo "Installing python3.12..."
  sudo apt install -y python3.12 python3.12-venv python3.12-dev
else
  echo "python3.12 already installed."
fi

if ! command -v uv &>/dev/null; then
  echo "Installing uv..."
  curl -LsSf https://astral.sh/uv/install.sh | sh
else
  echo "uv already installed."
fi

echo "Done. Python and uv ready."
```

**Step 2: Verify syntax**

Run: `bash -n modules/debian/08-python.sh`
Expected: no output

**Step 3: Commit**

```bash
git add modules/debian/08-python.sh
git commit -m "feat: add Debian module 08-python (deadsnakes PPA + uv)"
```

---

### Task 10: Create modules/debian/12-docker.sh

**Files:**
- Create: `modules/debian/12-docker.sh`

**Step 1: Create the module**

```bash
#!/usr/bin/env bash
set -e

echo "==> [12-DOCKER] Setting up Docker..."

if command -v docker &>/dev/null; then
  echo "Docker already installed."
else
  echo "Installing Docker via official repository..."

  sudo apt install -y ca-certificates curl gnupg

  sudo install -m 0755 -d /etc/apt/keyrings
  if [ ! -f /etc/apt/keyrings/docker.asc ]; then
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo tee /etc/apt/keyrings/docker.asc > /dev/null
    sudo chmod a+r /etc/apt/keyrings/docker.asc
  fi

  if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
  fi

  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

# Add current user to docker group if not already
if ! groups "$USER" | grep -q docker; then
  echo "Adding $USER to docker group..."
  sudo usermod -aG docker "$USER"
  echo "NOTE: Log out and back in for docker group membership to take effect."
else
  echo "$USER already in docker group."
fi

echo "Done. Docker installed (native Linux, no colima needed)."
```

**Step 2: Verify syntax**

Run: `bash -n modules/debian/12-docker.sh`
Expected: no output

**Step 3: Commit**

```bash
git add modules/debian/12-docker.sh
git commit -m "feat: add Debian module 12-docker (official Docker apt repo)"
```

---

### Task 11: Create modules/debian/13-dev-tools.sh

**Files:**
- Create: `modules/debian/13-dev-tools.sh`

**Step 1: Create the module**

```bash
#!/usr/bin/env bash
set -e

echo "==> [13-DEV-TOOLS] Installing developer tools..."

# Tools available via apt
APT_PACKAGES=(ripgrep)
for pkg in "${APT_PACKAGES[@]}"; do
  if dpkg -s "$pkg" &>/dev/null; then
    echo "$pkg already installed."
  else
    echo "Installing $pkg..."
    sudo apt install -y "$pkg"
  fi
done

# GitHub CLI via official apt repo
if ! command -v gh &>/dev/null; then
  echo "Installing GitHub CLI..."
  sudo mkdir -p -m 755 /etc/apt/keyrings
  if [ ! -f /etc/apt/keyrings/githubcli-archive-keyring.gpg ]; then
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | \
      sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
  fi
  sudo apt install -y gh
else
  echo "gh already installed."
fi

# lazygit via binary release
if ! command -v lazygit &>/dev/null; then
  echo "Installing lazygit..."
  LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
  curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
  tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
  sudo install /tmp/lazygit /usr/local/bin
  rm -f /tmp/lazygit /tmp/lazygit.tar.gz
else
  echo "lazygit already installed."
fi

# gdu via binary release
if ! command -v gdu &>/dev/null; then
  echo "Installing gdu..."
  curl -L https://github.com/dundee/gdu/releases/latest/download/gdu_linux_amd64.tgz | tar xz -C /tmp
  sudo install /tmp/gdu_linux_amd64 /usr/local/bin/gdu
  rm -f /tmp/gdu_linux_amd64
else
  echo "gdu already installed."
fi

# pnpm via npm (requires node from 09-node)
if command -v npm &>/dev/null; then
  if ! command -v pnpm &>/dev/null; then
    echo "Installing pnpm..."
    npm install -g pnpm
  else
    echo "pnpm already installed."
  fi
else
  echo "Skipping pnpm (npm not available yet — run after 09-node)."
fi

# temporal via binary release
if ! command -v temporal &>/dev/null; then
  echo "Installing temporal CLI..."
  curl -sSf https://temporal.download/cli.sh | sh
else
  echo "temporal already installed."
fi

# Sublime Text via official apt repository
if ! command -v subl &>/dev/null; then
  echo "Installing Sublime Text..."
  if [ ! -f /etc/apt/keyrings/sublimehq-pub.asc ]; then
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo tee /etc/apt/keyrings/sublimehq-pub.asc > /dev/null
  fi
  if [ ! -f /etc/apt/sources.list.d/sublime-text.sources ]; then
    echo -e 'Types: deb\nURIs: https://download.sublimetext.com/\nSuites: apt/stable/\nSigned-By: /etc/apt/keyrings/sublimehq-pub.asc' | sudo tee /etc/apt/sources.list.d/sublime-text.sources
    sudo apt update
  fi
  sudo apt install -y sublime-text
else
  echo "Sublime Text already installed."
fi

echo "Done. Developer tools installed."
```

**Step 2: Verify syntax**

Run: `bash -n modules/debian/13-dev-tools.sh`
Expected: no output

**Step 3: Commit**

```bash
git add modules/debian/13-dev-tools.sh
git commit -m "feat: add Debian module 13-dev-tools (apt + binary releases + Sublime apt repo)"
```

---

### Task 12: Create modules/debian/14-ai-tools.sh

**Files:**
- Create: `modules/debian/14-ai-tools.sh`

**Step 1: Create the module**

```bash
#!/usr/bin/env bash
set -e

echo "==> [14-AI-TOOLS] Installing AI coding tools..."

# Claude CLI via curl (same as macOS)
if ! command -v claude &>/dev/null; then
  echo "Installing Claude CLI..."
  curl -fsSL https://claude.ai/install.sh | bash
else
  echo "Claude CLI already installed."
fi

# copilot-cli via npm
if command -v npm &>/dev/null; then
  if ! command -v copilot &>/dev/null; then
    echo "Installing copilot-cli..."
    npm install -g @githubnext/github-copilot-cli
  else
    echo "copilot-cli already installed."
  fi
else
  echo "Skipping copilot-cli (npm not available — run after 09-node)."
fi

# codex via npm
if command -v npm &>/dev/null; then
  if ! command -v codex &>/dev/null; then
    echo "Installing codex..."
    npm install -g @openai/codex
  else
    echo "codex already installed."
  fi
else
  echo "Skipping codex (npm not available — run after 09-node)."
fi

# opencode via go install
if command -v go &>/dev/null; then
  if ! command -v opencode &>/dev/null; then
    echo "Installing opencode..."
    go install github.com/opencode-ai/opencode@latest
  else
    echo "opencode already installed."
  fi
else
  echo "Skipping opencode (go not available — run after 07-go)."
fi

echo "Done. AI tools installed."
```

**Step 2: Verify syntax**

Run: `bash -n modules/debian/14-ai-tools.sh`
Expected: no output

**Step 3: Commit**

```bash
git add modules/debian/14-ai-tools.sh
git commit -m "feat: add Debian module 14-ai-tools (npm + go install)"
```

---

### Task 13: Create modules/debian/16-fastfetch.sh

**Files:**
- Create: `modules/debian/16-fastfetch.sh`

**Step 1: Create the module**

```bash
#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> [16-FASTFETCH] Setting up fastfetch..."

if [ ! -d "$HOME/.oh-my-zsh/custom" ]; then
  echo "Oh My Zsh custom dir not found at ~/.oh-my-zsh/custom. Run 03-shell.sh first." >&2
  exit 1
fi

SRC="$SCRIPT_DIR/../../config/fastfetch.zsh"
DEST="$HOME/.oh-my-zsh/custom/fastfetch.zsh"

if [ ! -f "$SRC" ]; then
  echo "Source file not found: $SRC" >&2
  exit 1
fi

if ! command -v fastfetch &>/dev/null; then
  echo "Installing fastfetch..."
  sudo apt install -y fastfetch
else
  echo "fastfetch already installed."
fi

if [ ! -f "$DEST" ]; then
  echo "Deploying fastfetch.zsh to $DEST..."
  cp "$SRC" "$DEST"
else
  echo "fastfetch.zsh already exists at $DEST, skipping."
fi

echo "Done. fastfetch will run at most once per hour on shell start."
```

**Step 2: Verify syntax**

Run: `bash -n modules/debian/16-fastfetch.sh`
Expected: no output

**Step 3: Commit**

```bash
git add modules/debian/16-fastfetch.sh
git commit -m "feat: add Debian module 16-fastfetch"
```

---

### Task 14: Make config/environment.zsh platform-aware

**Files:**
- Modify: `modules/common/03-shell.sh`
- Modify: `config/environment.zsh`

**Step 1: Update config/environment.zsh to use conditional Python path**

Replace the Python section:

```bash
# Python via Homebrew
export PYTHON_HOME=/opt/homebrew/bin
export PATH="$PYTHON_HOME:$PATH"
alias python="$PYTHON_HOME/python3"
```

with:

```bash
# Python — platform-aware path
if [ -d "/opt/homebrew/bin" ]; then
  export PYTHON_HOME=/opt/homebrew/bin
elif [ -d "/usr/bin" ]; then
  export PYTHON_HOME=/usr/bin
fi
export PATH="$PYTHON_HOME:$PATH"
alias python="python3"
```

**Step 2: Verify syntax**

Run: `zsh -n config/environment.zsh`
Expected: no output

**Step 3: Commit**

```bash
git add config/environment.zsh
git commit -m "fix: make environment.zsh Python path platform-aware"
```

---

### Task 15: Update README.md

**Files:**
- Modify: `README.md`

**Step 1: Update README to reflect cross-platform support**

Key changes:
- Update tagline from "macOS dev environment" to "macOS and Debian dev environment"
- Update Prerequisites to include Debian
- Update module table to note platform-specific modules
- Update directory structure info
- Add Debian-specific notes (e.g., Docker runs natively, no colima)

Replace the header section:
```markdown
# fresh-squeezed 🍊

> No pulp, no bloat — just a freshly squeezed dev environment, ready to drink.

Automated, idempotent setup scripts for macOS and Debian developer machines. Installs and configures all the tools needed for software development and agentic coding.

## Prerequisites

- macOS (Apple Silicon or Intel) **or** Debian-based Linux (Debian, Ubuntu)
- Internet connection
- A GitHub account
```

Update the module table to indicate which are common vs platform-specific:

```markdown
## Modules

Modules are organized by platform:
- `modules/common/` — OS-agnostic, runs on all platforms
- `modules/darwin/` — macOS-specific (Homebrew)
- `modules/debian/` — Debian-specific (apt)

| Module | Platform | What it installs |
|--------|----------|-----------------|
| `00-ssh` | common | SSH key (ed25519) |
| `01-homebrew` | darwin | Homebrew package manager + `anomalyco/tap` |
| `01-apt-essentials` | debian | apt update + build-essential, curl, git, unzip, zsh |
| `02-xcode` | darwin | Xcode Command Line Tools |
| `03-shell` | common | Oh My Zsh + `config/environment.zsh` |
| `04-fonts` | darwin | Hack Nerd Font (brew cask) |
| `04-fonts` | debian | InconsolataGo Nerd Font Mono (GitHub release) |
| `05-neovim` | darwin | Neovim macOS binary + AstroNvim |
| `05-neovim` | debian | Neovim Linux binary + AstroNvim |
| `06-rust` | common | Rust via rustup + `tree-sitter-cli`, `bottom` |
| `07-go` | darwin | bison (brew) + GVM + Go 1.26.0 |
| `07-go` | debian | bison (apt) + GVM + Go 1.26.0 |
| `08-python` | darwin | Python 3.14 & 3.12 (Homebrew) + `uv` |
| `08-python` | debian | Python 3.14 & 3.12 (deadsnakes PPA) + `uv` |
| `09-node` | common | NVM + Node.js v24.13.1 |
| `10-java` | common | SDKMAN + Java 25.0.2-open |
| `11-dotnet` | common | .NET SDK (via dotnet-install.sh) |
| `12-docker` | darwin | Docker + Colima + docker-compose (brew) |
| `12-docker` | debian | Docker CE + docker-compose-plugin (official apt repo) |
| `13-dev-tools` | darwin | lazygit, gdu, temporal, pnpm, ripgrep, gh, Sublime Text (brew) |
| `13-dev-tools` | debian | lazygit, gdu, temporal, pnpm, ripgrep, gh, Sublime Text (apt + binary releases) |
| `14-ai-tools` | darwin | Claude CLI, copilot-cli, codex, opencode (brew) |
| `14-ai-tools` | debian | Claude CLI, copilot-cli, codex, opencode (curl + npm + go) |
| `15-zshrc-cleanup` | common | Moves installer-injected lines from `~/.zshrc` to `environment.zsh` |
| `16-fastfetch` | darwin | fastfetch (brew) + hourly config |
| `16-fastfetch` | debian | fastfetch (apt) + hourly config |
```

Add Debian-specific notes:
```markdown
## Debian Notes

- **Docker**: Runs natively on Linux — no colima needed. After setup, log out and back in for docker group membership.
- **Fonts**: InconsolataGo Nerd Font Mono is installed to `~/.fonts`.
- **Python**: Uses the deadsnakes PPA for Python 3.14 and 3.12.
- **sudo**: Several Debian modules require sudo for apt operations.
```

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: update README for cross-platform macOS + Debian support"
```

---

### Task 16: Final verification

**Step 1: Verify all files are in the right directories**

Run:
```bash
echo "=== common ===" && ls modules/common/
echo "=== darwin ===" && ls modules/darwin/
echo "=== debian ===" && ls modules/debian/
echo "=== orphans ===" && ls modules/*.sh 2>/dev/null || echo "(none)"
echo "=== lib ===" && ls lib/
```

Expected:
- `common/`: 00-ssh, 03-shell, 06-rust, 09-node, 10-java, 11-dotnet, 15-zshrc-cleanup
- `darwin/`: 01-homebrew, 02-xcode, 04-fonts, 05-neovim, 07-go, 08-python, 12-docker, 13-dev-tools, 14-ai-tools, 16-fastfetch
- `debian/`: 01-apt-essentials, 04-fonts, 05-neovim, 07-go, 08-python, 12-docker, 13-dev-tools, 14-ai-tools, 16-fastfetch
- orphans: (none)
- lib/: platform.sh

**Step 2: Verify all scripts parse cleanly**

Run:
```bash
for f in lib/platform.sh modules/common/*.sh modules/darwin/*.sh modules/debian/*.sh; do
  bash -n "$f" && echo "OK: $f" || echo "FAIL: $f"
done
```

Expected: all OK

**Step 3: Verify setup.sh parses and detects platform**

Run:
```bash
bash -n setup.sh && echo "setup.sh: OK"
bash setup.sh --list
```

Expected: prints module list for the detected platform (darwin on this machine)

**Step 4: Verify --module flag works**

Run:
```bash
bash setup.sh --module 00-ssh 2>&1 | head -3
```

Expected: should find and start running 00-ssh from common/
