# Ruby Setup with rv

## Why rv?

**rv** is a modern, fast Ruby version manager written in Rust. It's a drop-in replacement for rbenv but significantly faster.

- 🚀 **Fast:** Rust-based, no shell script overhead
- 🎯 **Simple:** Automatic version switching via `.ruby-version` files
- 🔄 **Compatible:** Works with existing `.ruby-version` files
- 🏗️ **Modern:** Focuses on current Ruby versions

**GitHub:** https://github.com/spinel-coop/rv

## Installation

```bash
# Install via cargo (Rust package manager)
cargo install rv
```

## Usage

### Install a Ruby version

```bash
rv ruby install 3.3.6
```

### Set project Ruby version

```bash
cd your-project
rv ruby pin 3.3.6
```

This creates a `.ruby-version` file in your project. rv automatically switches when you `cd` into the directory (configured in `oh-my-zsh-custom/ruby.zsh`).

### List installed versions

```bash
rv ruby list
```

### Find available versions

```bash
rv ruby find 3.3
```

## Older Ruby Versions

**rv doesn't support very old Ruby versions** (pre-2.6). For legacy projects:

1. Use **devcontainers** (preferred)
2. Keep old rbenv installation as fallback
3. Use Docker containers

### Example: Ruby 2.5 in devcontainer

```dockerfile
# .devcontainer/Dockerfile
FROM ruby:2.5

# Your dependencies...
```

## Migration from rbenv

1. **List your rbenv rubies:**
   ```bash
   rbenv versions
   ```

2. **Install them with rv:**
   ```bash
   rv ruby install 3.3.6
   rv ruby install 3.2.5
   # etc.
   ```

3. **Set project version:**
   ```bash
   cd your-project
   rv ruby pin 3.3.6
   ```

4. **Test:**
   ```bash
   ruby -v
   # Should show the rv-managed version
   ```

5. **Optional: Remove rbenv**
   ```bash
   rm -rf ~/.rbenv
   # Remove rbenv lines from old config files
   ```

## Troubleshooting

### rv not found

Make sure cargo bin is in your PATH:

```bash
# Already configured in zshrc
export PATH="$HOME/.cargo/bin:$PATH"
```

Restart terminal or `source ~/.zshrc`.

### Ruby version not switching

Check that you have `.ruby-version` in your project:

```bash
cat .ruby-version
```

Manually trigger rv:

```bash
eval "$(rv shell env zsh)"
ruby -v
```

### Build dependencies missing

rv uses pre-built binaries when possible, but may need build tools:

**Ubuntu/Debian:**
```bash
sudo apt install build-essential libssl-dev libreadline-dev zlib1g-dev
```

**macOS:**
```bash
xcode-select --install
```

## Current Setup

Our `ruby.zsh` configuration:

- ✅ Automatically loads rv on shell startup
- ✅ Auto-switches Ruby version when changing directories
- ✅ Platform detection (Linux/macOS paths)
- ✅ Helpful error if rv not installed

No manual activation needed - just `cd` into a project with `.ruby-version`!

---

**Need help?** Check the [rv GitHub repo](https://github.com/spinel-coop/rv) or open an issue.
