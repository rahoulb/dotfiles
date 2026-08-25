# Dotfiles

My personal dotfiles for ZSH, Neovim, Tmux, Git, and other development tools.

Works on **Ubuntu Linux** and **macOS**.

## 📁 Structure

```
dotfiles/
├── zsh/
│   ├── zshrc                      # Main ZSH configuration
│   ├── zshenv                     # Environment variables
│   └── oh-my-zsh-custom/          # oh-my-zsh custom configs
│       ├── aliases.zsh
│       ├── devpod.zsh
│       ├── linux.zsh              # Linux-specific config
│       ├── macos.zsh              # macOS-specific config
│       ├── paths.zsh
│       ├── python.zsh
│       ├── ruby.zsh
│       ├── ssh.zsh
│       └── yarn.zsh
├── nvim/                          # Neovim configuration
├── tmux/
│   └── tmux.conf
├── git/
│   └── gitconfig
├── ghostty/                       # Ghostty terminal config
├── syncthing/
│   └── ssh-ignores.txt            # Shared Syncthing ignore list for ~/.ssh
└── scripts/
    ├── install.sh                 # Automated installation
    └── backup-to-rsync.sh         # Daily backup script
```

### Syncthing and `~/.ssh`

`~/.ssh` is a Syncthing folder, shared device-to-device with no intermediate
server so that keys never touch a third party. A few things in there are
machine-local and must not sync — chiefly `agent.sock` and `ssh_auth_sock`,
which are symlinks to socket paths unique to one machine *and* one login
session.

Syncthing never syncs `.stignore` itself, so the list can't just be shared.
Instead each device gets a `.stignore` containing only `#include
ssh-ignores.txt`, and the payload lives inside `~/.ssh` where Syncthing does
distribute it. `install.sh` writes the `.stignore` and copies the payload.

**Edit the list in `syncthing/ssh-ignores.txt`, not in `~/.ssh`** — otherwise
your change is overwritten on the next `install.sh` run.

**On a new machine, run `install.sh` before adding the device to the SSH
folder.** A missing `#include` target is an error to Syncthing, and a device
that joins with no ignore list will push its own sockets into the index.

## 🚀 Quick Start

### First Time Setup

1. **Clone this repository:**
   ```bash
   cd ~/Developer
   git clone <your-repo-url> dotfiles
   cd dotfiles
   ```

2. **Install oh-my-zsh** (if not already installed):
   ```bash
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
   ```

3. **Install modern dev tools:**
   ```bash
   # rv - Fast Ruby version manager (replaces rbenv)
   cargo install rv
   ```

4. **Run the installation script:**
   ```bash
   ./scripts/install.sh
   ```

5. **Set up private configuration** (see below)

6. **Restart your terminal** or:
   ```bash
   source ~/.zshrc
   ```

### Private Configuration Setup

Secrets (API keys, SSH keys, connection strings) are stored separately in `~/Developer/private/` and synced via Syncthing.

**Create the private folder structure:**
```bash
mkdir -p ~/Developer/private/{ssh,env,echodek}
```

**Create secrets file** (`~/Developer/private/env/secrets.zsh`):
```zsh
# API Keys
export OPENAI_API_KEY="your-key-here"
export ANTHROPIC_API_KEY="your-key-here"
export ELEVENLABS_API_KEY="your-key-here"
export LINEAR_API_KEY="your-key-here"

# Other private environment variables
export DOCKER_HOSTNAME="your-hostname"
```

**Set up SSH keys:**
```bash
# Copy your SSH keys to the private folder
cp -r ~/.ssh/* ~/Developer/private/ssh/

# Then symlink them back (or use them directly)
ln -sf ~/Developer/private/ssh/config ~/.ssh/config
```

**Set up Syncthing** to sync `~/Developer/private/` across your machines (but NOT to NextCloud or external servers).

## 🔄 Updating

After making changes to your dotfiles:

```bash
cd ~/Developer/dotfiles
git add .
git commit -m "Update config"
git push
```

On other machines:
```bash
cd ~/Developer/dotfiles
git pull
```

Symlinks automatically point to the updated files - no need to reinstall!

## 💾 Automated Backups

Set up daily automated backups to rsync.net:

```bash
# Test the backup script first
~/Developer/dotfiles/scripts/backup-to-rsync.sh

# Add to crontab (runs daily at 2 AM)
crontab -e
# Add this line:
0 2 * * * /home/rahoulb/Developer/dotfiles/scripts/backup-to-rsync.sh
```

Logs are saved to `~/.backup-to-rsync.log`.

## 🔧 What's Excluded

**Not in this repo (stored in ~/Developer/private/):**
- SSH keys
- API keys and tokens
- Private connection strings
- Certificates

**Why?** Public dotfiles are shareable. Private credentials are not.

## 📦 Platform Detection

The config automatically detects Linux vs macOS and loads the appropriate settings:
- `oh-my-zsh-custom/linux.zsh` - Linux-specific
- `oh-my-zsh-custom/macos.zsh` - macOS-specific

## 🛠 Tools Configured

- **ZSH** with oh-my-zsh
- **Neovim** (custom config)
- **Tmux** (terminal multiplexer)
- **Git** (aliases and settings)
- **DevPod** (dev container management)
- **Node** (nvm, npm, bun, yarn)
- **Ruby** ([rv](https://github.com/spinel-coop/rv) - modern replacement for rbenv)
- **Python**
- **Docker**
- **Cargo** (Rust)

> **Note on Ruby:** We use `rv` instead of rbenv - it's faster and modern (Rust-based). For older Ruby versions that rv doesn't support, use devcontainers.

## 📝 License

Personal dotfiles - use at your own risk! 😊

---

**Last Updated:** 2026-01-27
