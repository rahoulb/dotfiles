# ============================================================================
# Ruby Version Management with rv
# ============================================================================
# rv is a modern, fast replacement for rbenv (Rust-based)
# https://github.com/spinel-coop/rv
#
# Installation:
#   cargo install rv
#
# For older Ruby versions that rv doesn't support, use devcontainers
# ============================================================================

# Ensure cargo is available (rv is installed via cargo)
[ -s "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# Load rv if installed
if command -v rv &> /dev/null; then
  autoload -U add-zsh-hook
  
  # Platform-specific rv setup
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS - rv installed via homebrew cargo
    _rv_autoload_hook() {
      eval "$(/opt/homebrew/bin/rv shell env zsh)"
    }
  else
    # Linux - rv installed via cargo
    _rv_autoload_hook() {
      eval "$($HOME/.cargo/bin/rv shell env zsh)"
    }
  fi
  
  # Auto-switch Ruby version when changing directories
  add-zsh-hook chpwd _rv_autoload_hook
  
  # Load rv for current directory
  _rv_autoload_hook
else
  # rv not installed - show helpful message once per session
  if [[ ! -v RV_NOT_INSTALLED_WARNED ]]; then
    echo "⚠️  rv not installed. Install with: cargo install rv"
    echo "   https://github.com/spinel-coop/rv"
    export RV_NOT_INSTALLED_WARNED=1
  fi
fi
