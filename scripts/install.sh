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
if [ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
  echo "⚠️  oh-my-zsh not installed. Run:"
  echo '  git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh'
else
  echo "  Installing oh-my-zsh custom files..."
  for custom_file in "$DOTFILES_DIR/zsh/oh-my-zsh-custom"/*.zsh; do
    filename=$(basename "$custom_file")
    safe_link "$custom_file" "$HOME/.oh-my-zsh/custom/$filename"
  done
  safe_link "$DOTFILES_DIR/zsh/oh-my-zsh-custom/themes/clueless.zsh-theme" \
    "$HOME/.oh-my-zsh/custom/themes/clueless.zsh-theme"
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
# Syncthing ignore list for ~/.ssh
# ============================================================================
# ~/.ssh is a Syncthing folder. Syncthing never syncs .stignore itself, so
# the ignore list cannot simply be shared — each device needs its own
# .stignore, which is why this runs here rather than being a symlink.
#
# The pattern: .stignore holds only an `#include`, and the payload it points
# at lives inside ~/.ssh so Syncthing distributes it. Copy it rather than
# symlinking — a symlink pointing out of the folder root is precisely the
# thing these ignores exist to keep out of the index.
#
# A missing #include target is an error to Syncthing, so on a new machine
# run this BEFORE adding the device to the SSH folder.
echo ""
echo "🔒 Installing Syncthing ignore list for ~/.ssh..."
if [ ! -d "$HOME/.ssh" ]; then
  echo "  ⏭️  No ~/.ssh yet — skipping"
else
  ssh_ignores_src="$DOTFILES_DIR/syncthing/ssh-ignores.txt"
  ssh_ignores_dst="$HOME/.ssh/ssh-ignores.txt"

  # Copy only when it differs: rewriting an identical file bumps its mtime,
  # which Syncthing sees as a change and re-propagates. Two machines doing
  # that at once is how you manufacture a sync-conflict out of nothing.
  if cmp -s "$ssh_ignores_src" "$ssh_ignores_dst"; then
    echo "  ✅ ssh-ignores.txt already current"
  else
    if [ -e "$ssh_ignores_dst" ]; then
      echo "  📦 Backing up existing ssh-ignores.txt"
      cp "$ssh_ignores_dst" "$BACKUP_DIR/"
    fi
    echo "  ✨ Copying ssh-ignores.txt"
    cp "$ssh_ignores_src" "$ssh_ignores_dst"
  fi

  # Back up any existing .stignore before replacing it. It is the only record
  # of what this device had been ignoring, and it exists nowhere else — not in
  # git, and not on the other devices, since Syncthing never carries it.
  if grep -qs '^#include ssh-ignores.txt' "$HOME/.ssh/.stignore"; then
    echo "  ✅ .stignore already includes it"
  else
    if [ -e "$HOME/.ssh/.stignore" ]; then
      echo "  📦 Backing up existing .stignore"
      cp "$HOME/.ssh/.stignore" "$BACKUP_DIR/stignore-$(hostname -s)"
    fi
    echo "  ✨ Writing .stignore"
    printf '#include ssh-ignores.txt\n// device-local additions below this line\n' > "$HOME/.ssh/.stignore"
  fi
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
echo "  2. Start a Zsh session: zsh"
echo "  3. Check everything works!"
echo ""
