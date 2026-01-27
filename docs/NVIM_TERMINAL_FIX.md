# Neovim Terminal State Fix

## Problem

After exiting nvim, tab-completion stops working in the terminal.

**Cause:** Flatpak version of nvim (`flatpak run io.neovim.nvim`) doesn't properly restore terminal settings on exit.

## Solution (Applied)

**Use the native nvim binary** instead of Flatpak:

```zsh
# In aliases.zsh (Linux only)
alias nvim="/opt/nvim-linux-x86_64/bin/nvim"
```

**Version:** v0.11.4 (native) vs v0.11.5 (Flatpak) - minimal difference

---

## Alternative: Temporary Workaround

If tab-completion breaks, run:

```bash
reset
# or
stty sane
```

This restores the terminal to normal state.

---

## Alternative: Wrapper Function

If you prefer to keep using Flatpak, wrap it with terminal state restoration:

```zsh
nvim() {
  local old_settings=$(stty -g)
  flatpak run io.neovim.nvim "$@"
  stty "$old_settings"
}
```

---

## Why Flatpak Breaks Terminal State

Flatpak apps run in a sandbox with limited access to system resources. The Neovim flatpak:

1. Changes terminal settings (raw mode, no echo, etc.)
2. Exits through the sandbox boundary
3. Terminal settings not properly restored
4. Tab-completion uses terminal settings → breaks

Native binaries don't have this issue as they have direct terminal access.

---

## Verifying the Fix

```bash
# Reload your config
source ~/.zshrc

# Check which nvim you're using
type nvim
# Should show: nvim is an alias for /opt/nvim-linux-x86_64/bin/nvim

# Test it
nvim test.txt
# (edit something, then :q)

# Try tab completion
cd ~/Deve<TAB>
# Should complete to ~/Developer/
```

Tab-completion should work! ✅

---

## If Native nvim is Missing

Install latest nvim AppImage:

```bash
# Download latest nvim
cd /tmp
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz

# Extract to /opt
sudo tar -C /opt -xzf nvim-linux64.tar.gz

# Update alias to point to it
# Edit: ~/Developer/dotfiles/zsh/oh-my-zsh-custom/aliases.zsh
alias nvim="/opt/nvim-linux64/bin/nvim"
```

---

## Status

- ✅ **Fixed:** Using native nvim on xstation
- ✅ **Mac:** Uses homebrew nvim (no issue)
- ✅ **Pushed to git:** Change synced to dotfiles repo

---

**Last Updated:** 2026-01-27
