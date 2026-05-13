#!/bin/sh
# attach-pismo.sh
#
# Opens two iTerm windows, each SSHing to pismo-beach and attaching one of
# the agent tmux sessions via iTerm's tmux integration (-CC mode), so each
# tmux window becomes a native iTerm window.
#
# Usage: attach-pismo.sh
#
# Host is Tailscale short-name so it works on any network the mesh covers.
# Swap to `pismo-beach.local` if you want strictly LAN/mDNS.

HOST="pismo-beach"

open_session() {
  name="$1"
  /usr/bin/osascript <<EOF
tell application "iTerm"
  activate
  tell current window 
    create tab with profile "${name}" command "ssh -t ${HOST} 'tmux -CC -u attach -t ${name}'"
  end tell
end tell
EOF
}

open_session "Cher"
open_session "Dionne"
