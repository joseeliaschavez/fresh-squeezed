#!/usr/bin/env bash
set -e

echo "==> [15-ZSHRC-CLEANUP] Moving installer-injected lines from ~/.zshrc to environment.zsh..."

ZSHRC="$HOME/.zshrc"
ENV_FILE="$HOME/.oh-my-zsh/custom/environment.zsh"

if [ ! -f "$ZSHRC" ]; then
  echo "~/.zshrc not found, nothing to clean up."
  exit 0
fi

if [ ! -f "$ENV_FILE" ]; then
  echo "environment.zsh not found at $ENV_FILE. Run 03-shell.sh first." >&2
  exit 1
fi

# Back up .zshrc before modifying
cp "$ZSHRC" "${ZSHRC}.bak"
echo "Backed up ~/.zshrc to ~/.zshrc.bak"

# Patterns injected by installers that belong in environment.zsh
PATTERNS=(
  "NVM_DIR"
  'nvm\.sh'
  'nvm/bash_completion'
  'SDKMAN_DIR'
  'sdkman-init\.sh'
  '\.cargo/env'
  '\.gvm/scripts/gvm'
  '\.dotnet'
  'PNPM_HOME'
  'pnpm/store'
)

MOVED=0
ENV_CONTENT=$(cat "$ENV_FILE")

for pattern in "${PATTERNS[@]}"; do
  # Find matching lines in .zshrc
  while IFS= read -r line; do
    # Skip empty lines and pure comments
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    # Only move if not already in environment.zsh
    if ! grep -qF "$line" "$ENV_FILE" 2>/dev/null; then
      echo "Moving to environment.zsh: $line"
      echo "$line" >> "$ENV_FILE"
      MOVED=$((MOVED + 1))
    fi
  done < <(grep -E "$pattern" "$ZSHRC" 2>/dev/null || true)

  # Remove matched lines from .zshrc. Use '#' as the sed delimiter since some
  # patterns (e.g. 'nvm/bash_completion') contain '/', which would otherwise
  # break the default /pattern/d syntax.
  sed -i.tmp -E "\#$pattern#d" "$ZSHRC"
done

# Clean up sed temp files
rm -f "${ZSHRC}.tmp"

echo ""
echo "Done. Moved $MOVED line(s) to $ENV_FILE."
echo "Review ~/.zshrc and environment.zsh, then run: source ~/.zshrc"
