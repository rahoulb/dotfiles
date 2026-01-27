
if [[ $(uname) == "Darwin" ]]; then
  export PATH=$PATH:$HOME/.local/bin:/opt/homebrew/bin:$HOME/Developer/flutter/bin:/opt/homebrew/opt/python@3.11/libexec/bin:$HOME/.ebcli-virtual-env/executables:$HOME/Library/Android/sdk/tools:$HOME/Library/platform-tools:"$HOME/.pub-cache/bin:$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:/opt/homebrew/opt/libpq/bin"
else 
  export PATH=$PATH:$HOME/.local/bin:$HOME/.cargo/env:/opt/nvim-linux-x86_64/bin:/home/rahoulb/.var/app/com.visualstudio.code/config/Code/User/globalStorage/ms-vscode-remote.remote-containers/cli-bin
fi




