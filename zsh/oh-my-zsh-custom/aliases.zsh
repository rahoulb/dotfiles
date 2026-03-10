# Aliases
alias dccup='docker compose -f .devcontainer/compose.yaml up -d'
alias dccsh='docker compose -f .devcontainer/compose.yaml exec rails-app bash -l'
alias dccdown='docker compose -f .devcontainer/compose.yaml down'
alias dcc='docker compose'
alias control='printf "\e]1;%s\a" "Control" && ssh -i $HOME/.ssh/rahoulb control@control.echodek.co'
alias python=python3
alias cher='openclaw'

if [[ $(uname) == "Darwin" ]]; then
  alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
  alias tmx="tmux -CC new -A -s rahoulb"

else
  alias tmx="tmux new -A -s rahoulb"
  # Use native nvim instead of flatpak (flatpak breaks terminal state)
  alias nvim="/opt/nvim-linux-x86_64/bin/nvim"

fi

