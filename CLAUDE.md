# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a professional cross-platform dotfiles repository for **macOS**, **Linux**, and **Windows 11**, managed by [chezmoi](https://www.chezmoi.io/). The repository includes automated installation scripts that handle all dependencies and setup with a single command for each platform.

## Repository Structure

```
.
├── .chezmoi.toml.tmpl          # Chezmoi config (cross-platform)
├── .chezmoiignore              # Platform ignore rules
├── .editorconfig               # Editor configuration
├── install/                     # Pre-chezmoi installers
│   ├── windows.ps1              # Windows 11
│   ├── macos.sh                 # macOS
│   └── linux.sh                 # Linux (all distros)
├── scripts/                     # Post-chezmoi scripts (run_once_)
│   ├── run_once_install_windows.ps1     # Windows apps
│   ├── run_once_install_macos.sh        # macOS apps + Homebrew
│   ├── run_once_install_opensuse.sh     # openSUSE apps
│   └── run_once_install_devtools.sh     # Dev tools (Unix)
├── dot_gitconfig.tmpl          # Git config with aliases
├── dot_bashrc.tmpl             # Bash configuration
├── dot_zshrc.tmpl              # Zsh configuration
├── dot_aliases                 # 100+ shell aliases
├── dot_functions               # Custom shell functions
├── dot_vimrc                   # Vim configuration
├── dot_tmux.conf               # Tmux configuration
├── .config/
│   ├── starship.toml           # Starship prompt
│   └── Code/User/              # VS Code settings
├── private_dot_ssh/            # SSH config (secure)
├── AppData/.../                # Windows Terminal config
├── .github/workflows/          # CI/CD pipelines
└── docs/                       # Documentation
```

## Key Architecture Concepts

### Installation Philosophy

Each platform has a **two-stage installation process**:

1. **Pre-chezmoi stage** (install/ scripts):
   - Handles platform-specific package manager installation
   - Installs core dependencies (git, curl, chezmoi)
   - Checks prerequisites (admin rights, sudo, etc.)
   - Initializes chezmoi with the dotfiles repository

2. **Post-chezmoi stage** (scripts/ with `run_once_` prefix):
   - Executed automatically by chezmoi after applying dotfiles
   - Installs additional applications and tools
   - Runs only once (tracked by chezmoi state)

### Platform-Specific Details

#### Windows (install/windows.ps1)

- **Prerequisites**: PowerShell 5.1+, Administrator privileges
- **Features**:
  - `#Requires -RunAsAdministrator` directive for privilege enforcement
  - Automatic winget installation if missing
  - Downloads and installs winget from GitHub releases
  - Installs Git, chezmoi, and curl via winget
  - Comprehensive error handling with colored output
  - PATH refresh after installations

**Key Functions**:
- `Test-Administrator` - Checks if running with admin privileges
- `Install-WinGet` - Downloads and installs winget automatically
- `Install-Package` - Wrapper for winget install with error handling
- `Update-EnvironmentPath` - Refreshes PATH without restarting shell

#### macOS (install/macos.sh)

- **Prerequisites**: macOS 10.15+ (Catalina or later)
- **Features**:
  - Installs Xcode Command Line Tools
  - Installs Homebrew package manager
  - Handles both Intel and Apple Silicon architectures
  - Installs git, curl, and chezmoi via Homebrew

#### Linux (install/linux.sh)

- **Prerequisites**: Supported distribution with sudo access
- **Supported Distributions**:
  - Debian/Ubuntu family (apt)
  - Fedora/RHEL family (dnf)
  - Arch Linux family (pacman)
  - openSUSE family (zypper)
- **Features**:
  - Automatic distribution detection via `/etc/os-release`
  - Uses appropriate package manager for detected distro
  - Falls back to universal chezmoi installer for unsupported distros

### Chezmoi Configuration (.chezmoi.toml.tmpl)

The configuration uses **template variables** for cross-platform compatibility:

- **Platform detection**: Automatically sets correct source directory based on OS
- **Template data**: Available variables: `name`, `email`, `username`
- **Interpreters**: Platform-specific script interpreters (PowerShell for Windows, bash for Unix)
- **Editor integration**: Configured to use VS Code for editing and merging
- **Safety features**: Prompts enabled for destructive operations

### Platform-Specific Package Installation Scripts

#### Windows (scripts/run_once_install_windows.ps1)

Applications are organized by **category** in a hashtable structure:

```powershell
$packageCategories = @{
    "Development Tools" = @(...)
    "Browsers" = @(...)
    "Communication" = @(...)
    # etc.
}
```

**Features**:
- Uses winget for package installation
- Checks if packages are already installed before attempting installation
- Tracks success/failure for summary report
- Continues on individual package failures
- Colored, categorized output for better UX

#### openSUSE (scripts/run_once_install_opensuse.sh)

**Features**:
- Uses zypper for native packages
- Uses Flatpak for sandboxed applications (Discord, Telegram, Steam)
- Automatically installs and configures Flatpak if needed
- Checks openSUSE detection before running
- Colored, categorized output matching Windows style

### Platform Isolation (.chezmoiignore)

The `.chezmoiignore` file ensures platform-specific scripts only run on their target platforms:

- Windows scripts are ignored on Linux/macOS
- macOS scripts are ignored on non-macOS systems
- openSUSE scripts are ignored on non-openSUSE systems
- Development tools script ignored on Windows
- Documentation files (README, LICENSE, .github) are not copied to target system
- Uses chezmoi template syntax for conditional ignores

### Dotfiles Management

#### Core Configuration Files

**Git (dot_gitconfig.tmpl)**:
- User info via template variables (`.name`, `.email`)
- 30+ useful aliases (l, s, d, go, amend, etc.)
- Platform-specific credential helpers
- Beautiful colored output
- Smart defaults (rebase, autostash, etc.)

**Shell (dot_bashrc.tmpl / dot_zshrc.tmpl)**:
- Colored prompt with git branch
- History optimization (10k+ lines, dedup)
- Platform-specific PATH configuration
- Auto-load nvm, pyenv, rust
- Homebrew integration (macOS)
- Welcome message with neofetch

**Aliases (dot_aliases)**:
- Navigation: .., ..., up
- Listing: l, la, lsd (colored, sorted)
- Git shortcuts: g, gs, ga, gc, gp, etc.
- Docker shortcuts: d, dc, dps, dex, etc.
- System-specific package managers
- Chezmoi shortcuts: ch, cha, chd, etc.

**Functions (dot_functions)**:
- mkcd: create and enter directory
- extract: universal archive extractor
- todos: find TODO comments
- backup: timestamp-based backups
- Docker helpers: denter, dstopall
- Network: httpstatus, speedtest
- Development: pyvenv, npminit, cloc

#### Development Tools Script (run_once_install_devtools.sh)

Automatically installs on Unix systems:

1. **Oh My Zsh** with plugins:
   - zsh-autosuggestions (fish-like completions)
   - zsh-syntax-highlighting

2. **nvm** (Node.js):
   - Latest LTS version
   - Global packages: yarn, pnpm, typescript, nodemon

3. **pyenv** (Python):
   - Latest stable Python
   - Tools: poetry, black, flake8, mypy, pytest

4. **rustup** (Rust):
   - Latest stable Rust
   - Cargo tools: cargo-edit, cargo-watch

All configured in shell rc files for instant availability.

#### Additional Configurations

**Starship (.config/starship.toml)**:
- Modern cross-shell prompt (Rust-based, fast)
- Shows git branch, status, language versions
- Docker context indicator
- Customizable format and colors
- Auto-loads in .bashrc and .zshrc if installed

**Tmux (dot_tmux.conf)**:
- Prefix changed to Ctrl+a (easier than Ctrl+b)
- Vi mode for copy/paste
- Vim-like pane navigation (hjkl)
- Mouse support enabled
- Beautiful status bar
- Session persistence support

**Vim (dot_vimrc)**:
- Line numbers and relative numbers
- Smart indentation
- Syntax highlighting
- Leader key: Space
- Persistent undo
- Mouse support
- File-type specific indentation

**SSH (private_dot_ssh/config.tmpl)**:
- ControlMaster for connection reusing (faster)
- Strong encryption ciphers
- Platform-specific settings (macOS keychain)
- Template variables for username/email
- Examples for GitHub, servers, jump hosts
- Security best practices

## Development Workflows

### Testing Installation Scripts

**Windows (local testing):**
```powershell
# Must run as Administrator
Set-ExecutionPolicy Bypass -Scope Process -Force
.\install\windows.ps1 -SkipChezmoi  # Test without initializing chezmoi
```

**macOS (local testing):**
```bash
SKIP_CHEZMOI=true ./install/macos.sh
```

**Linux (local testing):**
```bash
SKIP_CHEZMOI=true ./install/linux.sh
```

### Testing Chezmoi Integration

```bash
# Test initialization without applying
chezmoi init --source=/Users/dev.wladimir/Code/dotfiler

# Preview changes
chezmoi diff

# Dry run
chezmoi apply --dry-run

# Apply changes
chezmoi apply
```

### Re-running Scripts

Chezmoi tracks script execution state. To re-run `run_once_` scripts:

```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

### Modifying Windows Package List

Edit `scripts/run_once_install_windows.ps1`:

1. Locate the `$packageCategories` hashtable
2. Add/remove/modify categories or packages
3. Package IDs can be found via `winget search <app-name>`
4. Use either winget IDs (e.g., `Git.Git`) or Microsoft Store IDs (e.g., `9NKSQGP7F2NH`)

### Working with Chezmoi Templates

Files ending in `.tmpl` are processed by chezmoi's Go template engine:

```bash
# Add a regular file
chezmoi add ~/.gitconfig

# Add a template file
chezmoi add --template ~/.config/app/config.yaml
```

**Available template variables** (defined in `.chezmoi.toml.tmpl`):
- `{{ .name }}` - User's full name
- `{{ .email }}` - User's email
- `{{ .username }}` - System username
- `{{ .chezmoi.os }}` - OS (windows, darwin, linux)
- `{{ .chezmoi.arch }}` - Architecture (amd64, arm64, etc.)

### Platform-Specific Files

Use suffixes for platform-specific files:

- `config.yaml.windows` - Windows only
- `config.yaml.darwin` - macOS only
- `config.yaml.linux` - Linux only
- `config.yaml.tmpl` - Template processed on all platforms

## Important Notes

- **Remote execution**: All install scripts support remote execution via `irm`/`curl`
- **Error handling**: Scripts use strict mode and proper error handling
- **Idempotency**: All scripts can be run multiple times safely
- **Repository reference**: README uses `MeekoLab/dotfiles` but local development uses `dotfiler`
- **Script naming**: `run_once_` prefix is a chezmoi convention for one-time execution
- **Exit codes**: Scripts exit with code 1 on errors for CI/CD integration

## Code Style Guidelines

### PowerShell Scripts

- Use `[CmdletBinding()]` for advanced function features
- Always set `Set-StrictMode -Version Latest`
- Use `$ErrorActionPreference = 'Stop'` for main scripts
- Organize with `#region` blocks
- Use consistent helper functions: `Write-Step`, `Write-Success`, `Write-Warning`, `Write-ErrorMsg`
- Use approved verbs (Get, Set, Install, Test, etc.)

### Bash Scripts

- Use `#!/usr/bin/env bash` shebang
- Always set `set -euo pipefail` for safety
- Use ANSI color codes for output
- Define constants with `readonly`
- Organize with clear function sections
- Use lowercase with underscores for function names

## Testing Checklist

Before committing changes:

- [ ] Test Windows script in PowerShell as Administrator
- [ ] Test macOS script on Intel or Apple Silicon
- [ ] Test Linux script on at least one supported distro
- [ ] Verify chezmoi initialization works
- [ ] Check that scripts are idempotent (can run multiple times)
- [ ] Ensure proper error handling and user feedback
- [ ] Update README.md if adding new features
- [ ] Update this CLAUDE.md if architecture changes
