# openSUSE Tumbleweed Setup Guide

Quick reference guide for setting up openSUSE Tumbleweed with this dotfiles repository.

## Quick Installation

```bash
curl -fsLS https://raw.githubusercontent.com/MeekoLab/dotfiles/main/install/linux.sh | bash
```

## What Gets Installed

### Core Dependencies
- Git (version control)
- curl (data transfer)
- wget (network downloader)
- chezmoi (dotfiles manager)

### Applications (via run_once_install_opensuse.sh)

**Development Tools:**
- Visual Studio Code
- Git

**Browsers:**
- Chromium
- Firefox

**Communication (Flatpak):**
- Telegram
- Discord

**Multimedia:**
- VLC Media Player

**Utilities:**
- htop (process monitor)
- neofetch (system info)

**Gaming (Flatpak):**
- Steam

## Manual Installation Steps

If you prefer manual installation:

### 1. Install Base Requirements

```bash
sudo zypper refresh
sudo zypper install -y git curl wget
```

### 2. Install chezmoi

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"
```

### 3. Initialize Dotfiles

```bash
chezmoi init --apply https://github.com/MeekoLab/dotfiles
```

## Package Management

### Using zypper

```bash
# Search for packages
zypper search <package-name>

# Install package
sudo zypper install <package-name>

# Update system
sudo zypper refresh
sudo zypper update

# Remove package
sudo zypper remove <package-name>
```

### Using Flatpak

openSUSE scripts automatically install Flatpak for certain applications.

```bash
# Search Flathub
flatpak search <app-name>

# Install from Flathub
flatpak install flathub <app-id>

# List installed
flatpak list

# Update all
flatpak update

# Remove app
flatpak uninstall <app-id>
```

## Customizing Installed Packages

Edit `scripts/run_once_install_opensuse.sh` to add or remove packages:

```bash
chezmoi edit scripts/run_once_install_opensuse.sh
chezmoi apply
```

To re-run the installation script after changes:

```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

## Useful openSUSE Commands

### System Management

```bash
# Check openSUSE version
cat /etc/os-release

# System update
sudo zypper dup  # Distribution upgrade (for Tumbleweed)

# Clean package cache
sudo zypper clean
```

### YaST (openSUSE Admin Tool)

```bash
# Launch YaST (GUI)
sudo yast2

# Launch YaST (Terminal)
sudo yast2 -ncurses

# Specific YaST modules
sudo yast2 software        # Software management
sudo yast2 bootloader      # Boot loader settings
sudo yast2 network         # Network settings
```

## Troubleshooting

### Repository Issues

If you encounter repository problems:

```bash
# Refresh all repositories
sudo zypper refresh --force

# List repositories
zypper repos

# Clean cache
sudo zypper clean --all
```

### Flatpak Issues

If Flatpak apps don't appear in menu:

```bash
# Update desktop database
sudo update-desktop-database
```

### chezmoi Issues

```bash
# Check status
chezmoi status

# See what would change
chezmoi diff

# Verify configuration
chezmoi doctor

# Start fresh
rm -rf ~/.local/share/chezmoi
chezmoi init --apply https://github.com/MeekoLab/dotfiles
```

## Additional Resources

- [openSUSE Documentation](https://doc.opensuse.org/)
- [openSUSE Wiki](https://en.opensuse.org/)
- [chezmoi Documentation](https://www.chezmoi.io/)
- [Flathub Applications](https://flathub.org/)

## Notes

- **Tumbleweed** is a rolling release - update regularly with `sudo zypper dup`
- Some applications are installed via **Flatpak** for better sandboxing
- YaST is unique to openSUSE and very powerful for system configuration
- Repository snapshots ensure you can rollback if needed

---

**Made with ❤️ by [MeekoLab](https://github.com/MeekoLab)**
