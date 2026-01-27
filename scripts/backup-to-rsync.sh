#!/bin/bash
# ============================================================================
# Automated Backup to rsync.net
# ============================================================================
# Backs up critical directories to rsync.net storage
# Run daily via cron: 0 2 * * * /path/to/backup-to-rsync.sh

set -e

RSYNC_HOST="rsync.net"
RSYNC_BASE="backups"
LOG_FILE="$HOME/.backup-to-rsync.log"
DATE=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$DATE] Starting backup to $RSYNC_HOST..." | tee -a "$LOG_FILE"

# Function to safely rsync with error handling
safe_backup() {
  local source="$1"
  local dest="$2"
  local name="$3"
  
  if [ ! -d "$source" ]; then
    echo "  ⚠️  Skipping $name - directory not found: $source" | tee -a "$LOG_FILE"
    return
  fi
  
  echo "  📦 Backing up $name..." | tee -a "$LOG_FILE"
  
  if rsync -avz --delete \
    --exclude='.cache' \
    --exclude='node_modules' \
    --exclude='.git/objects' \
    --exclude='*.log' \
    --exclude='.DS_Store' \
    "$source/" "$RSYNC_HOST:$dest/" 2>&1 | tee -a "$LOG_FILE"; then
    echo "  ✅ $name backed up successfully" | tee -a "$LOG_FILE"
  else
    echo "  ❌ Failed to backup $name" | tee -a "$LOG_FILE"
  fi
}

# ============================================================================
# Backup Critical Directories
# ============================================================================

# Developer folder (code repositories)
safe_backup "$HOME/Developer" "$RSYNC_BASE/developer" "Developer"

# Private configuration (SSH keys, API keys)
safe_backup "$HOME/Developer/private" "$RSYNC_BASE/private" "Private"

# NextCloud documents
safe_backup "$HOME/Documents/NextCloud" "$RSYNC_BASE/nextcloud" "NextCloud"

# Obsidian Work Notes (optional - already synced via Obsidian Sync)
# safe_backup "$HOME/Documents/Work Notes" "$RSYNC_BASE/obsidian" "Obsidian"

# Dotfiles repo
safe_backup "$HOME/Developer/dotfiles" "$RSYNC_BASE/dotfiles" "Dotfiles"

# ============================================================================
# Done
# ============================================================================
DATE_END=$(date '+%Y-%m-%d %H:%M:%S')
echo "[$DATE_END] Backup complete!" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
