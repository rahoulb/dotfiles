# ---------------------------------------------------------------------------
# Stable agent socket
#
# tmux captures SSH_AUTH_SOCK when a session is created. Re-attaching from a
# different client (iMac -> MBP, or amber over mosh) hands tmux a fresh
# forwarded socket, but shells already running in existing panes keep exporting
# the old, now-dead path — so git push and friends break until the pane is
# recreated.
#
# Fix: every login shell *outside* tmux repoints ~/.ssh/agent.sock at whatever
# live agent it was handed; every shell then exports that fixed path. Panes
# follow the symlink, so they pick up the newest agent with no intervention.
#
# When the link goes dead — you attached from the iPad, that connection
# dropped, and you came back to a terminal that was already open — we have to
# rediscover a live agent. Note we cannot simply ask tmux: once shells export
# the link path, every subsequent client attach records *that* in the session
# environment, so tmux only ever hands back the symlink. Hence the candidate
# hunt below, which ends at the local launchd agent that is always present on
# the machine you're sitting at.
#
# Trade-off: with two clients attached at once, the most recent login wins.
# In practice either agent works, so this is harmless.
# ---------------------------------------------------------------------------

# Does this socket belong to an agent that answers? ssh-add exits 2 when it
# cannot connect at all; 0 (keys) and 1 (no keys) both mean reachable.
_ssh_agent_socket_live() {
  [[ -S "$1" ]] || return 1
  SSH_AUTH_SOCK="$1" ssh-add -l >/dev/null 2>&1
  [[ $? -ne 2 ]]
}

# Places a live agent might be found, best first.
_ssh_agent_socket_candidates() {
  local kv
  kv=$(tmux show-environment SSH_AUTH_SOCK 2>/dev/null)
  [[ "$kv" == SSH_AUTH_SOCK=* ]] && print -r -- "${kv#SSH_AUTH_SOCK=}"

  if [[ $(uname) == "Darwin" ]]; then
    print -rl -- /private/tmp/com.apple.launchd.*/Listeners(N)
  elif [[ -r "$HOME/.ssh/environment" ]]; then
    sed -n 's/^SSH_AUTH_SOCK=\([^;]*\).*/\1/p' "$HOME/.ssh/environment"
  fi
}

# Repoint the link at a live agent, then export the stable path.
# force=1 skips the healthy-link fast path and re-hunts regardless.
_ssh_agent_socket_link() {
  local link="$HOME/.ssh/agent.sock" force="$1" candidate

  # Fresh login shell: whatever ssh or launchd handed us wins outright.
  if [[ -z "$force" && -z "$TMUX" && -S "$SSH_AUTH_SOCK" && "$SSH_AUTH_SOCK" != "$link" ]]; then
    ln -sfn "$SSH_AUTH_SOCK" "$link"
  fi

  # Common path — link is healthy, so don't pay for probing on every shell.
  if [[ -z "$force" && -S "$link" ]]; then
    export SSH_AUTH_SOCK="$link"
    return 0
  fi

  # Link is dead (or we're forcing): hunt, and repoint it for *every* pane.
  for candidate in ${(f)"$(_ssh_agent_socket_candidates)"}; do
    [[ "$candidate" == "$link" ]] && continue
    if _ssh_agent_socket_live "$candidate"; then
      ln -sfn "$candidate" "$link"
      break
    fi
  done

  [[ -S "$link" ]] && export SSH_AUTH_SOCK="$link"
  return 0
}

# Repair panes whose agent died with an old connection. Repoints the link, so
# it fixes every pane in the session, not just the one you run it in.
fixssh() {
  _ssh_agent_socket_link force
  if _ssh_agent_socket_live "$SSH_AUTH_SOCK"; then
    echo "ssh agent ok  ->  $(readlink "$HOME/.ssh/agent.sock" 2>/dev/null)"
  else
    echo "no agent reachable — open a new terminal or reconnect, then retry"
    return 1
  fi
}

_ssh_agent_socket_link

if [[ $(uname) == "Darwin" ]]; then
  # only attempt agent operations if an agent is reachable
  if [[ -n "$SSH_AUTH_SOCK" ]] && ssh-add -l &>/dev/null; then
    ssh-add --apple-use-keychain --apple-load-keychain ~/.ssh/rahoulb 2>/dev/null
  elif [[ -z "$SSH_AUTH_SOCK" ]]; then
    # spin one up if there's truly nothing
    eval "$(ssh-agent -s)" >/dev/null
    ssh-add --apple-use-keychain --apple-load-keychain ~/.ssh/rahoulb 2>/dev/null
  fi
else
  SSH_ENV="$HOME/.ssh/environment"

  function start_agent {
      echo "Initialising new SSH agent..."
      /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
      echo succeeded
      chmod 600 "${SSH_ENV}"
      . "${SSH_ENV}" > /dev/null
      ssh-add ~/.ssh/rahoulb
  }

  # Source SSH settings, if applicable
  if [ -f "${SSH_ENV}" ]; then
      . "${SSH_ENV}" > /dev/null
      ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
          start_agent;
      }
  else
      start_agent;
  fi
fi

# Re-run: the branches above may have spawned a brand new agent, which needs
# to become the one the symlink points at.
_ssh_agent_socket_link

