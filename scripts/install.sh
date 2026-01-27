#!/bin/bash
# ============================================================================
# Dotfiles Installation Script
# ============================================================================
# Creates symlinks from home directory to dotfiles repo
# Run this after cloning the repo on a new machine

set -e

DOTFILES_DIR="$HOME/Developer/dotfiles"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

echo "🎯 Installing dotfiles from $DOTFILES_DIR"

# Create backup directory for existing files
mkdir -p "$BACKUP_DIR"

# Function to safely backup and symlink
safe_link() {
  local source="$1"
  local target="$2"
  
  # Create parent directory if needed
  mkdir -p "$(dirname "$target")"
  
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
