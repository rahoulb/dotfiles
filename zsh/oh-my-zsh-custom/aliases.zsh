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

# Git identity helpers
# The C8O repos are pinned to Tai Frasier via per-repo (.git/config) settings;
# the global identity is Rahoul Baruah. These help when *you* commit inside a
# repo that is otherwise set up as Tai.

# Commit a single commit as yourself, without changing the repo's identity.
# Everything else (including agent commits) stays as configured. Nothing to undo.
#   gcme -m "my own change"
alias gcme='git -c user.name="Rahoul Baruah" -c user.email="rahoulb@echodek.co" commit'

# Show or switch the current repo's local commit identity for a whole session.
# NOTE: while switched to "me", agent commits in this repo also become Rahoul -
# remember to switch back with `gitwho tai`.
#   gitwho          show the local + effective identity
#   gitwho me       set this repo to Rahoul Baruah <rahoulb@echodek.co>
#   gitwho tai      set this repo to Tai Frasier <tai@collabor8online.co.uk>
#   gitwho clear    remove the local override (fall back to the global identity)
gitwho() {
  case "$1" in
    me|rahoul)
      git config user.name "Rahoul Baruah"
      git config user.email "rahoulb@echodek.co"
      echo "This repo now commits as Rahoul Baruah <rahoulb@echodek.co>"
      ;;
    tai)
      git config user.name "Tai Frasier"
      git config user.email "tai@collabor8online.co.uk"
      echo "This repo now commits as Tai Frasier <tai@collabor8online.co.uk>"
      ;;
    clear|unset)
      git config --unset user.name 2>/dev/null
      git config --unset user.email 2>/dev/null
      echo "Cleared local override; using global: $(git config user.name) <$(git config user.email)>"
      ;;
    "")
      local lname lemail
      lname=$(git config --local user.name 2>/dev/null)
      lemail=$(git config --local user.email 2>/dev/null)
      if [[ -n "$lname" || -n "$lemail" ]]; then
        echo "Local override: ${lname:-?} <${lemail:-?}>"
      else
        echo "No local override (using global)."
      fi
      echo "Effective:      $(git config user.name) <$(git config user.email)>"
      ;;
    *)
      echo "usage: gitwho [me|tai|clear]"
      ;;
  esac
}

