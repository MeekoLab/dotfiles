# openSUSE Tumbleweed - Quick Start

## One-Line Installation

```bash
curl -fsLS https://raw.githubusercontent.com/MeekoLab/dotfiles/main/install/linux.sh | bash
```

## What Happens

1. ✅ Script detects openSUSE Tumbleweed
2. ✅ Installs git, curl, wget via zypper
3. ✅ Installs chezmoi
4. ✅ Initializes your dotfiles
5. ✅ Runs `run_once_install_opensuse.sh` automatically
6. ✅ Installs applications via zypper and Flatpak

## Installed Applications

**Via zypper:**
- Visual Studio Code
- Git
- Chromium
- Firefox
- VLC
- htop
- neofetch

**Via Flatpak:**
- Telegram
- Discord
- Steam

## Common Commands

```bash
# Update system (Tumbleweed)
sudo zypper dup

# Edit dotfiles
chezmoi edit <file>

# Apply changes
chezmoi apply

# Check status
chezmoi status

# Re-run install script
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

## Customize Packages

Edit package list:
```bash
chezmoi edit scripts/run_once_install_opensuse.sh
```

Then apply:
```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

## Full Documentation

See [opensuse-setup.md](./opensuse-setup.md) for detailed information.

---

**Made with ❤️ by [MeekoLab](https://github.com/MeekoLab)**
