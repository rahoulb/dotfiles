#!/bin/bash
# ============================================================================
# Dotfiles Installation Script
# ============================================================================
# Creates symlinks from home directory to dotfiles repo
# Run this after cloning the repo on a new machine

set -e

DOTFILES_DIR="$HOME/Developer/dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
PLAYWRIGHT_CACHE_DIR="$HOME/.cache/ms-playwright"

echo "🎯 Installing dotfiles from $DOTFILES_DIR"

# Create backup directory for existing files
mkdir -p "$BACKUP_DIR"

# Create Playwright cache folder
mkdir -p "$PLAYWRIGHT_CACHE_DIR"

# Function to safely backup and symlink
safe_link() {
  local source="$1"
  local target="$2"
  
  # Create parent directory if needed
  mkdir -p "$(dirname "$target")"
  
  # If target already links to the right place, do nothing
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
    echo "  ✅ Already linked $target -> $source"
    return 0
  fi

  # Backup existing file/directory if it exists and isn't already a symlink
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "  📦 Backing up existing $target"
    mv "$target" "$BACKUP_DIR/"
  elif [ -L "$target" ]; then
    echo "  🔗 Removing old symlink $target"
    rm "$target"
  fi
  
  # Create symlink
  echo "  ✨ Linking $target -> $source"
  ln -s "$source" "$target"
}

# ============================================================================
# ZSH Configuration
# ============================================================================
echo ""
echo "📝 Installing ZSH configuration..."
safe_link "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"
safe_link "$DOTFILES_DIR/zsh/zshenv" "$HOME/.zshenv"

# oh-my-zsh custom files
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "⚠️  oh-my-zsh not installed. Run:"
  echo "  sh -c \"\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
else
  echo "  Installing oh-my-zsh custom files..."
  for custom_file in "$DOTFILES_DIR/zsh/oh-my-zsh-custom"/*.zsh; do
    filename=$(basename "$custom_file")
    safe_link "$custom_file" "$HOME/.oh-my-zsh/custom/$filename"
  done
fi

# ============================================================================
# Neovim
# ============================================================================
echo ""
echo "📝 Installing Neovim configuration..."
safe_link "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"

# ============================================================================
# Tmux
# ============================================================================
echo ""
echo "📝 Installing Tmux configuration..."
safe_link "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

# ============================================================================
# Git
# ============================================================================
echo ""
echo "📝 Installing Git configuration..."
safe_link "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig"

# ============================================================================
# Ghostty (if config exists)
# ============================================================================
if [ -d "$DOTFILES_DIR/ghostty" ] && [ -f "$DOTFILES_DIR/ghostty/config" ]; then
  echo ""
  echo "📝 Installing Ghostty configuration..."
  safe_link "$DOTFILES_DIR/ghostty" "$HOME/.config/ghostty"
fi

# ============================================================================
# Moltbot/OpenClaw skills (shared via Nextcloud)
# ============================================================================
echo ""
echo "📝 Installing Moltbot/OpenClaw skills symlink..."

OS_NAME="$(uname -s)"
SKILLS_SOURCE=""

case "$OS_NAME" in
  Darwin)
    SKILLS_SOURCE="$HOME/NextCloud/Cher/skills"
    ;;
  Linux)
    SKILLS_SOURCE="$HOME/Documents/NextCloud/Cher/skills"
    ;;
  *)
    echo "  ⚠️  Unknown OS ($OS_NAME). Skipping ~/.clawdbot/skills symlink."
    SKILLS_SOURCE=""
    ;;
esac

if [ -n "$SKILLS_SOURCE" ]; then
  if [ -d "$SKILLS_SOURCE" ]; then
    safe_link "$SKILLS_SOURCE" "$HOME/.clawdbot/skills"
  else
    echo "  ⚠️  Skills source not found: $SKILLS_SOURCE"
    echo "     Skipping ~/.clawdbot/skills symlink (create the folder or mount Nextcloud first)."
  fi
fi

# ==========================================================================
# Cron: sync Nextcloud skills -> ~/.claude/skills (every 15 minutes)
# ==========================================================================

echo ""
echo "🕒 Installing cron job for syncing Claude skills..."

ensure_cron_job() {
  local marker="$1"
  local line="$2"

  # Read existing crontab (if any)
  local current
  current="$(crontab -l 2>/dev/null || true)"

  if echo "$current" | grep -Fq "$marker"; then
    echo "  ✅ Cron job already present ($marker)"
    return 0
  fi

  echo "  ✨ Adding cron job ($marker)"
  {
    echo "$current"
    echo "$marker"
    echo "$line"
  } | crontab -
}

# Ensure the sync script is executable (it lives in the repo)
chmod +x "$DOTFILES_DIR/scripts/sync-claude-skills.sh" 2>/dev/null || true

ensure_cron_job \
  "# dotfiles: sync Nextcloud skills to ~/.claude/skills" \
  "*/15 * * * * $DOTFILES_DIR/scripts/sync-claude-skills.sh >/dev/null 2>&1"

# ============================================================================
# Done!
# ============================================================================
echo ""
echo "✅ Dotfiles installation complete!"
echo ""
echo "Backup of old files: $BACKUP_DIR"
echo ""
echo "Next steps:"
echo "  1. Set up private config: ~/Developer/private/"
echo "  2. Restart your terminal or run: source ~/.zshrc"
echo "  3. Check everything works!"
echo ""
