# Remote Installer Design

**Date:** 2026-03-22
**Status:** Approved

## Problem

Users must manually clone the fresh-squeezed repo before running setup. We want a Rustup-style one-liner that anyone on the internet can run to install and set up their development environment.

## Approach

Single `install.sh` script in the repo root, served via GitHub raw URL. Users run:

```bash
curl -sSf https://raw.githubusercontent.com/joseeliaschavez/fresh-squeezed/develop/install.sh | bash
```

## Design

### Installer Flow

1. Print welcome banner with project name and description
2. Check prerequisites: `git` and `curl` must be available (fail with helpful message if missing)
3. Detect platform using `uname -s` and `/etc/debian_version` (same logic as `lib/platform.sh`)
4. Display summary: detected platform, install location (`~/.fresh-squeezed`), what will happen next
5. Prompt user: "Proceed with installation? [y/N]"
6. If `~/.fresh-squeezed` already exists: ask whether to update (`git pull`) or abort
7. Clone repo to `~/.fresh-squeezed` from `develop` branch
8. Execute `~/.fresh-squeezed/setup.sh`
9. Print completion message

### Script Requirements

- **POSIX `sh` compatible** — no bashisms; must work with `dash` on minimal Debian installs
- **Error handling**: `set -e` with a trap to print "installation failed" on error
- **No flags or arguments** — intentionally simple
- **Self-documenting**: comment header explaining what the script does for users who audit before running
- **Platform detection duplicated**: cannot source `lib/platform.sh` before the repo is cloned, so the detection logic is inlined

### Hosting

GitHub raw URL from the repo (`raw.githubusercontent.com`). No custom domain or GitHub Pages needed.

### Install Location

`~/.fresh-squeezed` — hidden directory in user's home, out of the way.

### Versioning

Always pulls latest from `develop` branch. No version pinning support.

### README Updates

- Feature the curl one-liner as the primary installation method
- Keep current "clone + run" approach as alternative for developers who fork/customize

## Files Changed

- `install.sh` (new) — the remote installer script
- `README.md` (modified) — updated installation instructions
