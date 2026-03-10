# ============================================================================
# mise — polyglot tool version manager
# https://mise.jdx.dev
# ============================================================================
# Activates mise for the current shell (zsh). Handles Linux and macOS paths.

if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
elif [ -x "$HOME/.local/bin/mise" ]; then
  eval "$($HOME/.local/bin/mise activate zsh)"
elif [ -x "/usr/bin/mise" ]; then
  eval "$(/usr/bin/mise activate zsh)"
fi
