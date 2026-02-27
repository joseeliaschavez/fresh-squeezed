# fresh-squeezed 🍊

> No pulp, no bloat — just a freshly squeezed macOS dev environment, ready to drink.

Automated, idempotent setup scripts for a macOS developer machine. Installs and configures all the tools needed for software development and agentic coding.

## Prerequisites

- macOS (Apple Silicon or Intel)
- Internet connection
- A GitHub account

## Usage

### Run the full setup

```bash
cd ~/Workspaces/Slalom/dev-setup
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

| Module | What it installs |
|--------|-----------------|
| `00-ssh` | SSH key (ed25519) — prompts for email, skipped if key exists |
| `01-homebrew` | Homebrew package manager + `anomalyco/tap` |
| `02-xcode` | Xcode Command Line Tools via `xcode-select --install` |
| `03-shell` | Oh My Zsh + deploys `config/environment.zsh` |
| `04-fonts` | Hack Nerd Font |
| `05-neovim` | Neovim (arch-aware binary) + AstroNvim config |
| `06-rust` | Rust via rustup + `tree-sitter-cli`, `bottom` |
| `07-go` | GVM + Go 1.26.0 |
| `08-python` | Python 3.14 & 3.12 (Homebrew) + `uv` |
| `09-node` | NVM + Node.js v24.13.1 |
| `10-java` | SDKMAN + Java 25.0.2-open |
| `11-dotnet` | .NET SDK (via dotnet-install.sh) |
| `12-docker` | Docker + Colima + docker-compose + CLI plugin symlink |
| `13-dev-tools` | lazygit, gdu, temporal, pnpm, ripgrep, gh (GitHub CLI), Sublime Text |
| `14-ai-tools` | Claude CLI, copilot-cli, codex, opencode |
| `15-zshrc-cleanup` | Moves installer-injected lines from `~/.zshrc` to `environment.zsh` |

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

## Config

`config/environment.zsh` is the ZSH environment template deployed by `03-shell`. It sets up:
- `~/.local/bin` on PATH
- Rust/Cargo
- Python (Homebrew)
- .NET
- GVM (Go)
- NVM (Node)
- SDKMAN (Java)
