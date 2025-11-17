# MeekoLab Dotfiles

[![CI](https://github.com/MeekoLab/dotfiles/workflows/Test%20Installation%20Scripts/badge.svg)](https://github.com/MeekoLab/dotfiles/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform: Windows](https://img.shields.io/badge/Platform-Windows%2011-0078D6?logo=windows)](https://www.microsoft.com/windows)
[![Platform: macOS](https://img.shields.io/badge/Platform-macOS-000000?logo=apple)](https://www.apple.com/macos)
[![Platform: Linux](https://img.shields.io/badge/Platform-Linux-FCC624?logo=linux)](https://www.linux.org/)
[![Powered by: chezmoi](https://img.shields.io/badge/Powered%20by-chezmoi-blue)](https://www.chezmoi.io/)

Cross-platform dotfiles and automated setup scripts for **macOS**, **Linux**, and **Windows 11**. Powered by [chezmoi](https://www.chezmoi.io/).

## ✨ Features

- 🚀 **One-command installation** on all platforms
- 🔄 **Automatic updates** via chezmoi
- 🎨 **Beautiful shell** with colors, prompts, and productivity tools
- 📦 **Package management** - auto-install essential apps
- 🛠️ **Dev tools setup** - nvm, pyenv, rustup preconfigured
- ⚙️ **Editor configs** - VS Code and terminal settings
- 🔒 **Secure** - no secrets in repo, optional encryption support
- 🧪 **Tested** - CI/CD with GitHub Actions
- 📝 **Well documented** - extensive guides and examples
- 🔖 **Automatic versioning** - git hooks for semantic versioning

## 🚀 Quick Installation

### Windows 11

> 💡 **Installing without Microsoft Account?** See [this guide](./docs/install-windows-without-ms-account.md)

Run in **PowerShell as Administrator**:

```powershell
irm https://raw.githubusercontent.com/MeekoLab/dotfiles/main/install/windows.ps1 | iex
```

**What it does:**
- ✅ Checks administrator privileges
- ✅ Installs winget automatically if missing
- ✅ Installs Git, chezmoi, and curl
- ✅ Initializes dotfiles with chezmoi
- ✅ Runs post-install scripts for applications

### macOS

Run in Terminal:

```bash
curl -fsLS https://raw.githubusercontent.com/MeekoLab/dotfiles/main/install/macos.sh | bash
```

**What it does:**
- ✅ Installs Xcode Command Line Tools
- ✅ Installs Homebrew
- ✅ Installs Git, curl, and chezmoi
- ✅ Initializes dotfiles with chezmoi

### Linux

Run in Terminal:

```bash
curl -fsLS https://raw.githubusercontent.com/MeekoLab/dotfiles/main/install/linux.sh | bash
```

**Supported distributions:**
- Ubuntu / Debian / Pop!_OS / Linux Mint
- Fedora / RHEL / CentOS
- Arch Linux / Manjaro / EndeavourOS
- openSUSE Tumbleweed / openSUSE Leap

> 💡 **Using openSUSE?** See the [openSUSE setup guide](./docs/opensuse-setup.md) for detailed instructions

**What it does:**
- ✅ Detects your Linux distribution
- ✅ Installs distribution-specific package manager packages
- ✅ Installs Git, curl, wget, and chezmoi
- ✅ Initializes dotfiles with chezmoi
- ✅ Runs distribution-specific post-install scripts

## 📦 What Gets Installed

### Core Dotfiles

Automatically configured on all platforms:
- **Git**: Enhanced `.gitconfig` with useful aliases and platform-specific settings
- **Shell**: `.bashrc` and `.zshrc` with colors, prompts, and productivity features
- **Starship**: Modern cross-shell prompt with git integration
- **Tmux**: Terminal multiplexer with vim-like keybindings
- **Vim**: Comfortable configuration for quick edits
- **Neovim**: Modern Vim with LSP, Treesitter, and plugin ecosystem
- **Terminals**: WezTerm (Windows), Ghostty (macOS/Linux) - GPU-accelerated terminals
- **SSH**: Secure SSH config template with examples
- **Aliases**: 100+ useful command aliases in `.aliases`
- **Functions**: Custom shell functions in `.functions`
- **Editor**: VS Code settings and Windows Terminal configuration
- **EditorConfig**: Consistent coding styles across editors

### Windows Applications

Automatically installed via winget (categorized):

**Development Tools:**
- Visual Studio Code
- Windows Terminal
- WezTerm (GPU-accelerated terminal)
- Neovim (modern Vim)

**Browsers:**
- Google Chrome

**Productivity:**
- Notion

**Communication:**
- WhatsApp
- Telegram
- Discord

**Gaming:**
- Steam
- Epic Games Launcher

**Hardware & Utilities:**
- Logitech G HUB
- Fan Control
- DeepCool

**VR & Streaming:**
- Meta Oculus
- Virtual Desktop Streamer

**System Tools:**
- Files App
- qBittorrent

> You can customize the package list in `scripts/run_once_install_windows.ps1`

### macOS Applications

Automatically installed via Homebrew:

**CLI Tools:**
- wget, tree, htop, neofetch
- jq (JSON processor)
- fzf (fuzzy finder), ripgrep, fd
- bat (cat alternative), exa (ls alternative)
- tldr, tmux
- Neovim (modern Vim)

**Git Tools:**
- Delta (better diffs)
- LazyGit
- GitHub CLI

**Development:**
- Node.js, Python 3, Go, Rust, Deno

**Applications:**
- Visual Studio Code, iTerm2
- Ghostty (GPU-accelerated terminal)
- Google Chrome, Firefox
- Discord, Telegram, Spotify
- VLC, Notion, Docker Desktop

**Fonts:**
- FiraCode Nerd Font
- JetBrains Mono Nerd Font
- Meslo Nerd Font

> Customize in `scripts/run_once_install_macos.sh`

### Development Tools (All Platforms)

Automatically installed via `scripts/run_once_install_devtools.sh`:

- **Oh My Zsh**: Enhanced shell with plugins
  - zsh-autosuggestions
  - zsh-syntax-highlighting
- **nvm**: Node.js version manager + latest LTS
  - Global packages: yarn, pnpm, typescript, nodemon
- **pyenv**: Python version manager + latest Python
  - Packages: pip, virtualenv, poetry, black, flake8, pytest
- **Rust**: Via rustup + cargo tools

## 🛠️ Managing Dotfiles

### Common Commands

```bash
# Check what would change
chezmoi diff

# Apply dotfile changes
chezmoi apply

# Edit a dotfile
chezmoi edit ~/.bashrc

# Update dotfiles from repository
chezmoi update

# Re-run scripts
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

### Adding New Files

```bash
# Add a file to dotfiles
chezmoi add ~/.gitconfig

# Add a template file
chezmoi add --template ~/.config/app/config.yaml
```

### Manual Initialization

If you skipped automatic initialization or want to reinitialize:

```bash
# Initialize and apply
chezmoi init --apply https://github.com/MeekoLab/dotfiles

# Or initialize without applying
chezmoi init https://github.com/MeekoLab/dotfiles
```

## 📁 Repository Structure

```
.
├── .chezmoi.toml.tmpl          # Chezmoi configuration (cross-platform)
├── .chezmoiignore              # Platform-specific ignore rules
├── .editorconfig               # Editor configuration
├── VERSION                      # Semantic version number
├── install/                     # Initial installation scripts
│   ├── windows.ps1              # Windows installer
│   ├── macos.sh                 # macOS installer
│   └── linux.sh                 # Linux installer (all distros)
├── scripts/                     # Post-install scripts (run_once_)
│   ├── run_once_install_windows.ps1       # Windows apps
│   ├── run_once_install_macos.sh          # macOS apps
│   ├── run_once_install_opensuse.sh       # openSUSE apps
│   ├── run_once_install_devtools.sh       # Dev tools (all Unix)
│   ├── run_once_install_git_hooks.sh      # Git hooks installer (Unix)
│   └── run_once_install_git_hooks.ps1     # Git hooks installer (Windows)
├── git-hooks/                   # Git hooks for auto-versioning
│   └── pre-push                 # Auto-increment version on push
├── dot_gitconfig.tmpl          # Git configuration
├── dot_bashrc.tmpl             # Bash configuration
├── dot_zshrc.tmpl              # Zsh configuration
├── dot_aliases                 # Shell aliases
├── dot_functions               # Shell functions
├── dot_vimrc                   # Vim configuration
├── dot_tmux.conf               # Tmux configuration
├── .config/                    # Application configs
│   ├── starship.toml           # Starship prompt config
│   └── Code/User/settings.json.tmpl     # VS Code settings
├── private_dot_ssh/            # SSH configuration
│   ├── config.tmpl             # SSH client config
│   └── sockets/                # ControlMaster sockets
├── AppData/                    # Windows-specific configs
│   └── Local/.../settings.json.tmpl     # Windows Terminal
├── .github/                    # CI/CD workflows
│   └── workflows/test.yml      # Automated testing
└── docs/                       # Documentation
    ├── install-windows-without-ms-account.md
    ├── opensuse-setup.md
    └── opensuse-quickstart.md
```

## 🔖 Versioning

This repository uses **automatic semantic versioning** via git hooks. The version is automatically incremented on each `git push`.

### How It Works

- **VERSION file**: Contains the current version (e.g., `1.0.0`)
- **Git hook**: `pre-push` hook automatically increments the patch version (works on all platforms via Git Bash on Windows)
- **Auto-installation**: The git hooks are installed automatically via platform-specific scripts:
  - **Unix/macOS/Linux**: `scripts/run_once_install_git_hooks.sh`
  - **Windows**: `scripts/run_once_install_git_hooks.ps1`

### Version Format

Follows [Semantic Versioning](https://semver.org/): `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes (manual update required)
- **MINOR**: New features, backwards compatible (manual update required)
- **PATCH**: Bug fixes, small changes (auto-incremented on push)

### Manual Version Updates

To manually bump major or minor versions:

```bash
# Bump major version (e.g., 1.0.0 → 2.0.0)
echo "2.0.0" > VERSION
git add VERSION
git commit -m "chore: bump major version to 2.0.0"

# Bump minor version (e.g., 1.0.0 → 1.1.0)
echo "1.1.0" > VERSION
git add VERSION
git commit -m "chore: bump minor version to 1.1.0"
```

The next `git push` will then increment the patch version (e.g., `2.0.0` → `2.0.1`).

### Platform Notes

**Windows**:
- Requires [Git for Windows](https://git-scm.com/download/win) (automatically installed by `install/windows.ps1`)
- The pre-push hook is a bash script that runs via Git Bash (included with Git for Windows)
- The hook installation script is PowerShell-based for Windows compatibility

**macOS/Linux**:
- Uses native bash for both hook installation and execution
- No additional requirements beyond standard git

### Reinstalling Git Hooks

If you need to reinstall the git hooks:

**Unix/macOS/Linux:**
```bash
# Re-run the installation script
./scripts/run_once_install_git_hooks.sh

# Or via chezmoi
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

**Windows:**
```powershell
# Re-run the installation script
.\scripts\run_once_install_git_hooks.ps1

# Or via chezmoi
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

## 🔧 Advanced Usage

### Skip chezmoi Initialization

**Windows:**
```powershell
irm https://raw.githubusercontent.com/MeekoLab/dotfiles/main/install/windows.ps1 | iex -SkipChezmoi
```

**macOS/Linux:**
```bash
SKIP_CHEZMOI=true curl -fsLS https://raw.githubusercontent.com/MeekoLab/dotfiles/main/install/macos.sh | bash
```

### Custom Repository

```bash
# Windows
$env:DOTFILES_REPO = "https://github.com/yourusername/dotfiles"
.\install\windows.ps1

# macOS/Linux
DOTFILES_REPO="https://github.com/yourusername/dotfiles" ./install/macos.sh
```

## 📝 Customization

### Edit User Information

Update `.chezmoi.toml.tmpl` with your details:

```toml
[data]
  name = "Your Name"
  email = "your@email.com"
```

### Customize Windows Packages

Edit `scripts/run_once_install_windows.ps1` and modify the `$packageCategories` hashtable to add/remove applications.

### Platform-Specific Files

Chezmoi supports platform-specific files using suffixes:

- `.windows` - Windows only
- `.darwin` - macOS only
- `.linux` - Linux only

Example: `config.yaml.windows`, `bashrc.linux`

## 🤝 Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest improvements
- Add new features
- Share your dotfile configurations

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [chezmoi](https://www.chezmoi.io/) - Dotfile manager
- [Homebrew](https://brew.sh/) - macOS package manager
- [winget](https://github.com/microsoft/winget-cli) - Windows package manager

---

**Made with ❤️ by [MeekoLab](https://github.com/MeekoLab)**
