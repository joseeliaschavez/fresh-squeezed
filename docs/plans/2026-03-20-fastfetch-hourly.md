# Fastfetch Hourly Session Display Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Run `fastfetch` automatically at the start of each terminal session, but at most once per hour, by adding a new `fresh-squeezed` module.

**Architecture:** A new Zsh snippet (`config/fastfetch.zsh`) holds the hourly-gate logic using a timestamp file; it is deployed to `~/.oh-my-zsh/custom/fastfetch.zsh` by a new setup module (`modules/16-fastfetch.sh`). Oh My Zsh auto-sources all `.zsh` files in its `custom/` directory, so no changes to `~/.zshrc` are needed. `setup.sh` is updated to include the new module.

**Tech Stack:** Bash (module script), Zsh (shell snippet), Homebrew (package check), Oh My Zsh custom directory

---

### Task 1: Create `config/fastfetch.zsh` — the hourly-check snippet

**Files:**
- Create: `config/fastfetch.zsh`

**Step 1: Create the file**

```zsh
# Run fastfetch at most once per hour
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

Save this content to `config/fastfetch.zsh`.

**Step 2: Manually verify the snippet works**

Source it in your current shell and confirm fastfetch runs (first time, no timestamp file exists):

```bash
source config/fastfetch.zsh
```

Expected: fastfetch output appears. Run again immediately — fastfetch should NOT run a second time (timestamp was just written).

**Step 3: Commit**

```bash
git add config/fastfetch.zsh
git commit -m "feat: add fastfetch hourly-check zsh snippet"
```

---

### Task 2: Create `modules/16-fastfetch.sh` — setup module

**Files:**
- Create: `modules/16-fastfetch.sh`

**Step 1: Create the module**

```bash
#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> [16-FASTFETCH] Setting up fastfetch..."

if ! brew list fastfetch &>/dev/null; then
  echo "Installing fastfetch..."
  brew install fastfetch
else
  echo "fastfetch already installed."
fi

SRC="$SCRIPT_DIR/../config/fastfetch.zsh"
DEST="$HOME/.oh-my-zsh/custom/fastfetch.zsh"

if [ ! -f "$DEST" ]; then
  echo "Deploying fastfetch.zsh to $DEST..."
  cp "$SRC" "$DEST"
else
  echo "fastfetch.zsh already exists at $DEST, skipping."
fi

echo "Done. fastfetch will run at most once per hour on shell start."
```

Save this content to `modules/16-fastfetch.sh`.

**Step 2: Make the module executable**

```bash
chmod +x modules/16-fastfetch.sh
```

**Step 3: Run the module and verify**

```bash
bash modules/16-fastfetch.sh
```

Expected output:
```
==> [16-FASTFETCH] Setting up fastfetch...
fastfetch already installed.
Deploying fastfetch.zsh to /Users/<you>/.oh-my-zsh/custom/fastfetch.zsh...
Done. fastfetch will run at most once per hour on shell start.
```

Verify the file was deployed:

```bash
ls ~/.oh-my-zsh/custom/fastfetch.zsh
```

Expected: file exists.

**Step 4: Run the module again to confirm idempotency**

```bash
bash modules/16-fastfetch.sh
```

Expected: "fastfetch already installed." and "fastfetch.zsh already exists at ..., skipping." — no errors, no duplicate deploys.

**Step 5: Commit**

```bash
git add modules/16-fastfetch.sh
git commit -m "feat: add module 16-fastfetch to deploy fastfetch zsh config"
```

---

### Task 3: Register `16-fastfetch` in `setup.sh`

**Files:**
- Modify: `setup.sh` lines 7–24 (the `MODULES` array)

**Step 1: Add the module to the array**

In `setup.sh`, find the `MODULES=(...)` array and append `"16-fastfetch"` after `"15-zshrc-cleanup"`:

```bash
MODULES=(
  "00-ssh"
  "01-homebrew"
  "02-xcode"
  "03-shell"
  "04-fonts"
  "05-neovim"
  "06-rust"
  "07-go"
  "08-python"
  "09-node"
  "10-java"
  "11-dotnet"
  "12-docker"
  "13-dev-tools"
  "14-ai-tools"
  "15-zshrc-cleanup"
  "16-fastfetch"
)
```

**Step 2: Verify `--list` shows the new module**

```bash
bash setup.sh --list
```

Expected: `16-fastfetch` appears at the bottom of the list.

**Step 3: Verify `--module` flag runs it cleanly**

```bash
bash setup.sh --module 16-fastfetch
```

Expected: same output as Task 2 Step 4 (idempotent second run).

**Step 4: Commit**

```bash
git add setup.sh
git commit -m "feat: register 16-fastfetch in setup.sh module list"
```

---

### Task 4: End-to-end verification

**Step 1: Delete the timestamp file to simulate a fresh state**

```bash
rm -f "${XDG_CACHE_HOME:-$HOME/.cache}/fastfetch_last_run"
```

**Step 2: Open a new terminal and confirm fastfetch runs**

Open a new terminal window/tab. Fastfetch output should appear automatically.

**Step 3: Open another terminal immediately**

Open a second tab within a minute. Fastfetch should NOT run again (timestamp was written in Step 2).

**Step 4: Simulate an hour passing and confirm re-run**

```bash
# Set the timestamp to 61 minutes ago
echo $(( $(date +%s) - 3660 )) > "${XDG_CACHE_HOME:-$HOME/.cache}/fastfetch_last_run"
```

Open a new terminal (or source `~/.zshrc`). Fastfetch should run again.

**Step 5: Final commit (if any cleanup needed)**

```bash
git add -A
git commit -m "chore: finalize fastfetch hourly display setup"
```
