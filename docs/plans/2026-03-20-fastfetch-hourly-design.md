# Fastfetch Hourly Session Display — Design

## Problem

`fastfetch` is installed via Homebrew. It should run automatically at the start of each terminal session, but at most once per hour — so opening many tabs/windows in quick succession doesn't repeat the output.

## Approach

Add a new `fresh-squeezed` module (`16-fastfetch`) that:
1. Ensures `fastfetch` is installed via Homebrew.
2. Deploys a Zsh snippet to `~/.oh-my-zsh/custom/fastfetch.zsh`, which Oh My Zsh auto-sources on every shell start.

The snippet performs an hourly-gate check using a timestamp file before running `fastfetch`.

## Files

| File | Action |
|---|---|
| `config/fastfetch.zsh` | New — hourly-check Zsh snippet |
| `modules/16-fastfetch.sh` | New — setup module |
| `setup.sh` | Modified — add `16-fastfetch` to `MODULES` array |

## Hourly-check Logic (`config/fastfetch.zsh`)

```zsh
_FASTFETCH_STAMP="${XDG_CACHE_HOME:-$HOME/.cache}/fastfetch_last_run"

if command -v fastfetch &>/dev/null; then
  mkdir -p "$(dirname "$_FASTFETCH_STAMP")"
  _now=$(date +%s)
  _last=$(cat "$_FASTFETCH_STAMP" 2>/dev/null || echo 0)
  if (( _now - _last >= 3600 )); then
    fastfetch
    echo "$_now" > "$_FASTFETCH_STAMP"
  fi
  unset _now _last
fi
unset _FASTFETCH_STAMP
```

- Uses `~/.cache/fastfetch_last_run` (respects `$XDG_CACHE_HOME` if set).
- Cleans up shell variables after use.
- Gracefully skips if `fastfetch` is not found.

## Setup Module (`modules/16-fastfetch.sh`)

- Checks `brew list fastfetch`; installs if missing.
- Copies `config/fastfetch.zsh` → `~/.oh-my-zsh/custom/fastfetch.zsh` if not already present.
- Idempotent: safe to run multiple times.

## Design Decisions

- **Why `~/.oh-my-zsh/custom/`?** Oh My Zsh auto-sources all `.zsh` files in this directory, keeping `~/.zshrc` clean — consistent with how `environment.zsh` is managed.
- **Why a timestamp file vs cron?** No background process needed; the check happens naturally at shell startup.
- **Why unset variables?** Avoids polluting the user's shell environment with internal state.
