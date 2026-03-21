# Cross-Platform Support: macOS + Debian

## Problem

The setup scripts and modules are macOS/Homebrew-only. We need them to also run on Linux Debian using `apt` where possible, while keeping a single codebase.

## Approach

**Platform-specific module directories** — split modules into `common/`, `darwin/`, and `debian/` directories. OS-agnostic modules live in `common/` (unchanged). Platform-specific modules get separate implementations in their respective directories. `setup.sh` auto-detects the OS, merges modules from `common/` + the platform dir, sorts by numeric prefix, and runs them in order.

## Directory Structure

```
lib/
  platform.sh              # detect_platform() → "darwin" | "debian" | "unsupported"
modules/
  common/                  # OS-agnostic modules (unchanged logic)
    00-ssh.sh
    03-shell.sh
    06-rust.sh
    09-node.sh
    10-java.sh
    11-dotnet.sh
    15-zshrc-cleanup.sh
  darwin/                  # macOS modules (current versions, moved here)
    01-homebrew.sh
    02-xcode.sh
    04-fonts.sh
    05-neovim.sh
    07-go.sh
    08-python.sh
    12-docker.sh
    13-dev-tools.sh
    14-ai-tools.sh
    16-fastfetch.sh
  debian/                  # Debian equivalents (new)
    01-apt-essentials.sh
    04-fonts.sh
    05-neovim.sh
    07-go.sh
    08-python.sh
    12-docker.sh
    13-dev-tools.sh
    14-ai-tools.sh
    16-fastfetch.sh
config/
  environment.zsh          # Platform-aware Python path
```

## Platform Detection (lib/platform.sh)

```bash
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

## setup.sh Changes

1. Source `lib/platform.sh` and set `PLATFORM=$(detect_platform)`
2. Exit with clear error if unsupported
3. Build module list by globbing `modules/common/*.sh` + `modules/$PLATFORM/*.sh`, sorted by numeric prefix
4. `--module` flag searches both `common/` and `$PLATFORM/` dirs
5. `--list` shows which modules will run for the detected platform

## Debian Module Details

### 01-apt-essentials.sh

Replaces both `01-homebrew` and `02-xcode` on macOS.

- `sudo apt update && sudo apt upgrade -y`
- `sudo apt install -y build-essential curl git unzip zsh`

### 04-fonts.sh

- Download InconsolataGo Nerd Font Mono from nerd-fonts v3.4.0 release:
  `https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/InconsolataGo.zip`
- Unzip to `~/.fonts`
- Run `fc-cache -fv`

### 05-neovim.sh

- Download `nvim-linux-x86_64.tar.gz` from GitHub releases (no `xattr` call)
- Symlink to `~/.local/bin/nvim`
- Clone AstroNvim template (same as macOS)

### 07-go.sh

- `sudo apt install -y bison` (instead of `brew install bison`)
- GVM install via curl (same as macOS)

### 08-python.sh

- Add `deadsnakes` PPA for Python 3.14 and 3.12
- `sudo apt install -y python3.14 python3.12`
- Install `uv` via curl (same as macOS)

### 12-docker.sh

- Install via official Docker apt repository (`docker-ce`, `docker-compose-plugin`)
- No colima — Docker runs natively on Linux
- Set up docker-compose CLI plugin symlink

### 13-dev-tools.sh

- `sudo apt install -y ripgrep`
- `gh` via GitHub's official apt repository
- `lazygit`, `gdu` via binary releases from GitHub
- `pnpm` via npm
- `temporal` via binary release or npm
- Sublime Text via Sublime's official apt repository (GPG key + stable channel)

### 14-ai-tools.sh

- Claude CLI via curl (same as macOS)
- `copilot-cli` via npm
- `codex` via npm
- `opencode` via `go install` or binary release

### 16-fastfetch.sh

- `sudo apt install -y fastfetch`
- Deploy `fastfetch.zsh` config (same as macOS)

## Config Changes

### config/environment.zsh

The Python path section needs to be platform-aware:

- **macOS:** `export PYTHON_HOME=/opt/homebrew/bin`
- **Debian:** `export PYTHON_HOME=/usr/bin`

Options: either make `03-shell.sh` do a sed replacement at deploy time based on platform, or split into `config/environment.darwin.zsh` and `config/environment.debian.zsh`.

## Modules That Stay Unchanged

These modules use curl-based installers or version managers and are already OS-agnostic:

- `00-ssh.sh` — `ssh-keygen`
- `03-shell.sh` — Oh My Zsh via curl
- `06-rust.sh` — rustup via curl
- `09-node.sh` — NVM via curl
- `10-java.sh` — SDKMAN via curl
- `11-dotnet.sh` — dotnet-install.sh via curl
- `15-zshrc-cleanup.sh` — file manipulation only
