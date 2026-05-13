# Aliases
alias devup="devcontainer up --workspace-folder . && devcontainer exec --workspace-folder . bash -l"
alias devsh='devcontainer exec --workspace-folder . bash -l'
alias devdown='docker compose -f .devcontainer/compose.yaml down'
alias devexec="devcontainer exec --workspace-folder . bash -lc"
alias control='printf "\e]1;%s\a" "Control" && ssh -i $HOME/.ssh/rahoulb control@control.echodek.co'
alias python=python3
alias cher="ssh -i $HOME/.ssh/rahoulb rahoulb@pismo-beach 'tmux -CC attach -t Cher'"
alias dionne="ssh -i $HOME/.ssh/rahoulb rahoulb@pismo-beach 'tmux -CC attach -t Dionne'"
alias tai="ssh -i $HOME/.ssh/rahoulb rahoulb@tai 'tmux -CC attach -t Tai'"

if [[ $(uname) == "Darwin" ]]; then
  alias tailscale="/Applications/Tailscale.app/Contents/MacOS/Tailscale"
  alias tmx="tmux -CC new -A -s rahoulb"
else
  alias tmx="tmux new -A -s rahoulb"
fi

