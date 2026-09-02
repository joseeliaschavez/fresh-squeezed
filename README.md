# fresh-squeezed 🍊

> No pulp, no bloat — just a freshly squeezed dev environment, ready to drink.

Automated, idempotent setup scripts for macOS and Debian developer machines. Installs and configures all the tools needed for software development and agentic coding.

## Prerequisites

- macOS (Apple Silicon or Intel) **or** Debian-based Linux (Debian, Ubuntu)
- Internet connection
- A GitHub account

## Quick Install

Run this in your terminal:

```bash
curl -sSf https://raw.githubusercontent.com/joseeliaschavez/fresh-squeezed/develop/install.sh | bash
```

This will:
1. Check that `git` and `curl` are installed
2. Detect your platform (macOS or Debian)
3. Clone the repo to `~/.fresh-squeezed`
4. Run the full setup

> **Tip:** You can [inspect the script](https://github.com/joseeliaschavez/fresh-squeezed/blob/develop/install.sh) before running it.

## Manual Install

If you prefer to clone manually or want to customize:

```bash
git clone https://github.com/joseeliaschavez/fresh-squeezed.git ~/.fresh-squeezed
cd ~/.fresh-squeezed
./setup.sh
```

### Run a single module

```bash
./setup.sh --module 05-neovim
```

### List all modules

```bash
./setup.sh --list
```

## Modules

Modules are organized by platform:
- `modules/common/` — OS-agnostic, runs on all platforms
- `modules/darwin/` — macOS-specific (Homebrew)
- `modules/debian/` — Debian-specific (apt)

| Module | Platform | What it installs |
|--------|----------|-----------------|
| `00-ssh` | common | SSH key (ed25519) — prompts for email, skipped if key exists |
| `01-homebrew` | darwin | Homebrew package manager + `anomalyco/tap` |
| `01-apt-essentials` | debian | apt update + build-essential, curl, git, unzip, zsh |
| `02-xcode` | darwin | Xcode Command Line Tools via `xcode-select --install` |
| `03-shell` | common | Oh My Zsh + deploys `config/environment.zsh` |
| `04-fonts` | darwin | Hack Nerd Font |
| `04-fonts` | debian | InconsolataGo Nerd Font Mono (GitHub release) |
| `05-neovim` | darwin | Neovim (macOS binary) + AstroNvim config |
| `05-neovim` | debian | Neovim (Linux binary) + AstroNvim config |
| `06-rust` | common | Rust via rustup + `tree-sitter-cli`, `bottom` |
| `07-go` | darwin | bison (brew) + GVM + Go 1.26.0 |
| `07-go` | debian | bison (apt) + GVM + Go 1.26.0 |
| `08-python` | darwin | Python 3.14 & 3.12 (Homebrew) + `uv` |
| `08-python` | debian | Python 3.14 & 3.12 (deadsnakes PPA) + `uv` |
| `09-node` | common | NVM + Node.js v24.13.1 |
| `10-java` | common | SDKMAN + Java 25.0.2-open |
| `11-dotnet` | common | .NET SDK (via dotnet-install.sh) |
| `12-docker` | darwin | Docker + Colima + docker-compose + CLI plugin symlink |
| `12-docker` | debian | Docker CE + docker-compose-plugin (official apt repo) |
| `13-dev-tools` | darwin | lazygit, gdu, temporal, pnpm, ripgrep, gh, Sublime Text |
| `13-dev-tools` | debian | lazygit, gdu, temporal, pnpm, ripgrep, gh, Sublime Text (apt + binary releases) |
| `14-ai-tools` | darwin | Claude CLI, copilot-cli, codex, opencode |
| `14-ai-tools` | debian | Claude CLI, copilot-cli, codex, opencode (curl + npm + go) |
| `15-zshrc-cleanup` | common | Moves installer-injected lines from `~/.zshrc` to `environment.zsh` |
| `16-fastfetch` | common | fastfetch + hourly config |
| `18-vimrc` | common | amix/vimrc ("The Ultimate vimrc") for classic Vim |

## Notes

- **Idempotent**: Every module checks whether a tool is already installed before running. Safe to re-run.
- **SSH key**: Module `00-ssh` prompts for your email and prints your public key. Add it to GitHub at https://github.com/settings/keys before cloning private repos.
- **Xcode tools**: Module `02-xcode` launches a GUI dialog. Wait for it to finish, then press Enter to continue.
- **Start Colima**: After `12-docker` runs, start Colima with:
  ```bash
  colima start --network-address --cpu 4 --memory 8
  ```
- **ZSH config**: All environment variables and PATH entries live in `~/.oh-my-zsh/custom/environment.zsh`. The `15-zshrc-cleanup` module moves any installer-injected lines from `~/.zshrc` there.
- **After setup**: Run `source ~/.zshrc` to apply all environment changes.

## Debian Notes

- **Docker**: Runs natively on Linux — no colima needed. After setup, log out and back in for docker group membership.
- **Fonts**: InconsolataGo Nerd Font Mono is installed to `~/.fonts`.
- **Python**: Uses the deadsnakes PPA for Python 3.14 and 3.12.
- **sudo**: Several Debian modules require sudo for apt operations.

## Config

`config/environment.zsh` is the ZSH environment template deployed by `03-shell`. It sets up:
- `~/.local/bin` on PATH
- Rust/Cargo
- Python (platform-aware)
- .NET
- GVM (Go)
- NVM (Node)
- SDKMAN (Java)
