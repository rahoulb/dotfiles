#!/usr/bin/env bash
set -euo pipefail

# Sync OpenClaw-managed skills into ~/.openclaw/skills
# Source: ~/OpenClaw/skills (git repo)
# Used by cron (every 15 minutes) and can be run manually.

SOURCE_DIR="$HOME/OpenClaw/skills"
TARGET_DIR="$HOME/.openclaw/skills"

# Skip if source folder not present
if [ ! -d "$SOURCE_DIR" ]; then
  echo "Skills source not found: $SOURCE_DIR (skipping)" >&2
  exit 0
fi

mkdir -p "$TARGET_DIR"

# Mirror contents (delete removed files). Exclude common cruft.
rsync -a --delete \
  --exclude '.DS_Store' \
  --exclude '.git/' \
  --exclude 'node_modules/' \
  "$SOURCE_DIR/" "$TARGET_DIR/"

