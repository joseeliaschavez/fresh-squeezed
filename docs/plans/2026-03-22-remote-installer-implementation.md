# Remote Installer Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a curl-pipe-bash installer so users can set up their dev environment with a single command.

**Architecture:** A single POSIX `sh`-compatible `install.sh` at the repo root. It checks prerequisites, detects the platform, prompts for confirmation, clones the repo to `~/.fresh-squeezed`, and runs `setup.sh`. The README is updated to feature this as the primary install method.

**Tech Stack:** POSIX shell (`#!/bin/sh`), git, curl

**Design doc:** `docs/plans/2026-03-22-remote-installer-design.md`

---

### Task 1: Create the install.sh script

**Files:**
- Create: `install.sh`

**Step 1: Create `install.sh` with the following content**

```sh
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
```

**Step 2: Make the script executable**

Run: `chmod +x install.sh`

**Step 3: Verify the script parses cleanly with sh and bash**

Run: `bash -n install.sh && sh -n install.sh && echo "OK"`
Expected: `OK`

**Step 4: Commit**

```bash
git add install.sh
git commit -m "feat: add remote installer script

Enables one-liner installation via:
  curl -sSf https://raw.githubusercontent.com/.../install.sh | bash

- POSIX sh compatible (works with dash on Debian)
- Checks prerequisites (git, curl)
- Detects platform (macOS/Debian)
- Prompts before proceeding
- Handles existing installations (offers update)
- Clones to ~/.fresh-squeezed and runs setup.sh"
```

---

### Task 2: Update README with one-liner install instructions

**Files:**
- Modify: `README.md`

**Step 1: Update the README**

Replace the current Usage section (lines 13-30) with a new "Quick Install" section as the primary method, followed by the existing manual method as an alternative. The new content:

```markdown
## Quick Install

Run this in your terminal:

\`\`\`bash
curl -sSf https://raw.githubusercontent.com/joseeliaschavez/fresh-squeezed/develop/install.sh | bash
\`\`\`

This will:
1. Check that `git` and `curl` are installed
2. Detect your platform (macOS or Debian)
3. Clone the repo to `~/.fresh-squeezed`
4. Run the full setup

> **Tip:** You can [inspect the script](https://github.com/joseeliaschavez/fresh-squeezed/blob/develop/install.sh) before running it.

## Manual Install

If you prefer to clone manually or want to customize:

\`\`\`bash
git clone https://github.com/joseeliaschavez/fresh-squeezed.git ~/.fresh-squeezed
cd ~/.fresh-squeezed
./setup.sh
\`\`\`

### Run a single module

\`\`\`bash
./setup.sh --module 05-neovim
\`\`\`

### List all modules

\`\`\`bash
./setup.sh --list
\`\`\`
```

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add one-liner install to README

Features curl-pipe-bash as primary install method.
Moves existing clone-and-run to 'Manual Install' section."
```

---

### Task 3: Verify end-to-end

**Files:** None (verification only)

**Step 1: Verify install.sh parses with both sh and bash**

Run: `bash -n install.sh && sh -n install.sh && echo "Parse OK"`
Expected: `Parse OK`

**Step 2: Verify the script uses no bashisms**

Run: `grep -n 'BASH_SOURCE\|\[\[.*\]\]\|function \w\+()\|source ' install.sh || echo "No bashisms found"`
Expected: `No bashisms found`

**Step 3: Verify the raw GitHub URL will be correct**

Run: `echo "https://raw.githubusercontent.com/joseeliaschavez/fresh-squeezed/develop/install.sh"`
Manually confirm this path matches the file location in the repo root.

**Step 4: Verify README references the correct URL**

Run: `grep "raw.githubusercontent.com" README.md`
Expected: The URL matches the one in install.sh's header comment.
