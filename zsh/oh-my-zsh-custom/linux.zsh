# Linux-specific configuration

# Flatpak directories
if [ -d "/var/lib/flatpak/exports/share" ]; then
  export XDG_DATA_DIRS="/var/lib/flatpak/exports/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
fi

if [ -d "$HOME/.local/share/flatpak/exports/share" ]; then
  export XDG_DATA_DIRS="$HOME/.local/share/flatpak/exports/share:${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
fi

# OpenClaw Completion
source "/home/rahoulb/.openclaw/completions/openclaw.zsh"

# Linux-specific paths (if not already in paths.zsh)
export PATH="$PATH:$HOME/.local/bin"

