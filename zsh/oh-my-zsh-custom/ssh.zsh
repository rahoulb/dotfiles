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

