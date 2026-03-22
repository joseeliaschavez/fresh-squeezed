# Default Environment

# Set the .local/bin path to PATH
export PATH="$PATH:$HOME/.local/bin"

# Setup Rust and Cargo
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Python — platform-aware path
if [ -d "/opt/homebrew/bin" ]; then
  export PYTHON_HOME=/opt/homebrew/bin
elif [ -d "/usr/bin" ]; then
  export PYTHON_HOME=/usr/bin
fi
export PATH="$PYTHON_HOME:$PATH"
alias python="python3"

# Dotnet
export PATH="$PATH:$HOME/.dotnet"

# Go Version Manager
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"

# Node Version Manager
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
