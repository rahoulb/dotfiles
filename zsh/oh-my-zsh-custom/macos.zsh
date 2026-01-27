# macOS-specific configuration

# Android SDK (if installed)
if [ -d "$HOME/Library/Android/sdk" ]; then
  export ANDROID_HOME="$HOME/Library/Android/sdk"
  export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
fi

# macOS-specific utilities
export PATH="$PATH:$HOME/.local/bin"
