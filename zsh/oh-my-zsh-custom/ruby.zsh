source $HOME/.cargo/env

if command -v rv; then 
  autoload -U add-zsh-hook
  if [[ $(uname) == "Darwin" ]]; then
    _rv_autoload_hook () {
        eval "$(/opt/homebrew/bin/rv shell env zsh)"
    }  
  else
    _rv_autoload_hook () {
        eval "$(/home/rahoulb/.cargo/bin/rv shell env zsh)"
    }
  fi
  add-zsh-hook chpwd _rv_autoload_hook
  _rv_autoload_hook
fi

