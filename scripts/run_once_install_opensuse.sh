#!/usr/bin/env bash
#
# Chezmoi post-install script for openSUSE applications
# Automatically executed by chezmoi after applying dotfiles on openSUSE systems
# This script runs only once (run_once_ prefix)
#
# Author: MeekoLab

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
readonly NC='\033[0m' # No Color

#region Helper Functions

print_step() {
    echo -e "${CYAN}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

print_category() {
    echo ""
    echo -e "${MAGENTA}━━━ $1 ━━━${NC}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

check_opensuse() {
    if [[ ! -f /etc/os-release ]]; then
        print_error "Cannot detect OS"
        return 1
    fi

    . /etc/os-release
    if [[ "$ID" != "opensuse"* && "$ID" != "suse" ]]; then
        print_warning "This script is designed for openSUSE"
        return 1
    fi

    print_success "Running on openSUSE"
    return 0
}

install_package() {
    local package="$1"
    local description="$2"

    print_step "Installing $description..."

    # Check if already installed
    if rpm -q "$package" &>/dev/null; then
        print_success "$description is already installed"
        return 0
    fi

    # Install package
    if sudo zypper install -y "$package" &>/dev/null; then
        print_success "$description installed successfully"
        return 0
    else
        print_error "Failed to install $description"
        return 1
    fi
}

install_flatpak_package() {
    local app_id="$1"
    local description="$2"

    print_step "Installing $description (via Flatpak)..."

    # Ensure Flatpak is installed
    if ! command_exists flatpak; then
        print_step "Installing Flatpak..."
        sudo zypper install -y flatpak
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    fi

    # Check if already installed
    if flatpak list | grep -q "$app_id"; then
        print_success "$description is already installed"
        return 0
    fi

    # Install flatpak
    if flatpak install -y flathub "$app_id" &>/dev/null; then
        print_success "$description installed successfully"
        return 0
    else
        print_error "Failed to install $description"
        return 1
    fi
}

#endregion

#region Main Installation

main() {
    print_step "Starting openSUSE application installation..."
    echo ""

    # Check if running on openSUSE
    if ! check_opensuse; then
        print_error "Exiting: Not running on openSUSE"
        exit 1
    fi

    # Track results
    local -a success_packages=()
    local -a failed_packages=()

    # Development Tools
    print_category "Development Tools"

    if install_package "code" "Visual Studio Code"; then
        success_packages+=("Visual Studio Code")
    else
        failed_packages+=("Visual Studio Code")
    fi

    if install_package "git" "Git"; then
        success_packages+=("Git")
    else
        failed_packages+=("Git")
    fi

    # Browsers
    print_category "Browsers"

    if install_package "chromium" "Chromium"; then
        success_packages+=("Chromium")
    else
        failed_packages+=("Chromium")
    fi

    if install_package "firefox" "Firefox"; then
        success_packages+=("Firefox")
    else
        failed_packages+=("Firefox")
    fi

    # Communication (via Flatpak)
    print_category "Communication"

    if install_flatpak_package "org.telegram.desktop" "Telegram"; then
        success_packages+=("Telegram")
    else
        failed_packages+=("Telegram")
    fi

    if install_flatpak_package "com.discordapp.Discord" "Discord"; then
        success_packages+=("Discord")
    else
        failed_packages+=("Discord")
    fi

    # Multimedia
    print_category "Multimedia"

    if install_package "vlc" "VLC Media Player"; then
        success_packages+=("VLC")
    else
        failed_packages+=("VLC")
    fi

    # Utilities
    print_category "Utilities"

    if install_package "htop" "htop"; then
        success_packages+=("htop")
    else
        failed_packages+=("htop")
    fi

    if install_package "neofetch" "neofetch"; then
        success_packages+=("neofetch")
    else
        failed_packages+=("neofetch")
    fi

    if install_package "tmux" "tmux"; then
        success_packages+=("tmux")
    else
        failed_packages+=("tmux")
    fi

    if install_package "neovim" "Neovim"; then
        success_packages+=("Neovim")
    else
        failed_packages+=("Neovim")
    fi

    # Terminal Emulator
    print_category "Terminal Emulator"

    if install_flatpak_package "com.mitchellh.ghostty" "Ghostty"; then
        success_packages+=("Ghostty")
    else
        failed_packages+=("Ghostty")
    fi

    # Starship prompt
    if ! command_exists starship; then
        print_step "Installing Starship prompt..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y &>/dev/null
        if command_exists starship; then
            print_success "Starship installed successfully"
            success_packages+=("Starship")
        else
            print_error "Failed to install Starship"
            failed_packages+=("Starship")
        fi
    else
        print_success "Starship is already installed"
        success_packages+=("Starship")
    fi

    # Gaming (via Flatpak)
    print_category "Gaming"

    if install_flatpak_package "com.valvesoftware.Steam" "Steam"; then
        success_packages+=("Steam")
    else
        failed_packages+=("Steam")
    fi

    # Summary
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}          Installation Summary           ${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    if [[ ${#success_packages[@]} -gt 0 ]]; then
        echo -e "${GREEN}✓ Successfully installed: ${#success_packages[@]} packages${NC}"
    fi

    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        echo -e "${RED}✗ Failed: ${#failed_packages[@]} packages${NC}"
        echo -e "${RED}  Failed packages:${NC}"
        for pkg in "${failed_packages[@]}"; do
            echo -e "${RED}    - $pkg${NC}"
        done
    fi

    echo ""
    echo -e "${GREEN}All essential programs installation completed!${NC}"
    echo ""

    # Exit with error code if there were failures
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        print_warning "Some packages failed to install. You may want to install them manually."
        exit 1
    fi
}

# Run main installation only on Linux
if [[ "$(uname)" == "Linux" ]]; then
    main "$@"
else
    print_error "This script is for Linux only"
    exit 1
fi

#endregion
