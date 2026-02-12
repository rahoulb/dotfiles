#!/usr/bin/env bash
set -euo pipefail

# Sync Nextcloud-managed Moltbot/OpenClaw skills into ~/.claude/skills
# Used by cron (every 15 minutes) and can be run manually.

OS_NAME="$(uname -s)"

case "$OS_NAME" in
  Darwin)
    SOURCE_DIR="$HOME/NextCloud/Agents/Shared/skills"
    ;;
  Linux)
    SOURCE_DIR="$HOME/Documents/NextCloud/Agents/Shared/skills"
    ;;
  *)
    echo "Unknown OS ($OS_NAME); refusing to sync skills." >&2
    exit 0
    ;;
esac

TARGET_DIR="$HOME/.claude/skills"

# Skip if Nextcloud folder not present (don’t create broken sync noise)
if [ ! -d "$SOURCE_DIR" ]; then
  echo "Skills source not found: $SOURCE_DIR (skipping)" >&2
  exit 0
fi

mkdir -p "$TARGET_DIR"

# Mirror contents (delete removed files). Exclude common cruft.
rsync -a --delete \
  --exclude '.DS_Store' \
  --exclude '.git/' \
  "$SOURCE_DIR/" "$TARGET_DIR/"
