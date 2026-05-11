# macOS-specific configuration

# Android SDK (if installed)
if [ -d "$HOME/Library/Android/sdk" ]; then
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
fi

# macOS-specific utilities
export PATH="$PATH:$HOME/.local/bin"
export OPENCLAW_GATEWAY_TOKEN="f9ef407ff67ad8729abe321b93874683f38023965a824256"
