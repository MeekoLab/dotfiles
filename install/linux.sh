#!/usr/bin/env bash
#
# Linux dotfiles installer for MeekoLab
# Run: curl -fsLS https://raw.githubusercontent.com/MeekoLab/dotfiles/main/install/linux.sh | bash
#
# Author: MeekoLab
# Supports: Ubuntu, Debian, Fedora, Arch Linux, openSUSE

set -euo pipefail

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
readonly NC='\033[0m' # No Color

# Configuration
readonly DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/MeekoLab/dotfiles}"
readonly SKIP_CHEZMOI="${SKIP_CHEZMOI:-false}"

#region Helper Functions

print_banner() {
    echo -e "${MAGENTA}"
    cat << 'EOF'
+-------------------------------------------------------+
| $$\      $$\                     $$\                  |
| $$$\    $$$ |                    $$ |                 |
| $$$$\  $$$$ | $$$$$$\   $$$$$$\  $$ |  $$\  $$$$$$\   |
| $$\$$\$$ $$ |$$  __$$\ $$  __$$\ $$ | $$  |$$  __$$\  |
| $$ \$$$  $$ |$$$$$$$$ |$$$$$$$$ |$$$$$$  / $$ /  $$ | |
| $$ |\$  /$$ |$$   ____|$$   ____|$$  _$$<  $$ |  $$ | |
| $$ | \_/ $$ |\$$$$$$$\ \$$$$$$$\ $$ | \$$\ \$$$$$$  | |
| \__|     \__| \_______| \_______|\__|  \__| \______/  |
|                                                       |
|                  @MeekoLab/dotfiles                   |
+-------------------------------------------------------+
EOF
    echo -e "${NC}"
}

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

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

detect_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        echo "$ID"
    elif [[ -f /etc/lsb-release ]]; then
        . /etc/lsb-release
        echo "$DISTRIB_ID" | tr '[:upper:]' '[:lower:]'
    else
        echo "unknown"
    fi
}

check_sudo() {
    print_step "Checking sudo privileges..."

    if ! sudo -n true 2>/dev/null; then
        print_warning "This script requires sudo privileges"
        sudo -v
    fi

    print_success "Sudo privileges verified"
}

install_dependencies_debian() {
    print_step "Installing dependencies for Debian/Ubuntu..."

    sudo apt-get update
    sudo apt-get install -y git curl wget

    # Install chezmoi
    if ! command_exists chezmoi; then
        print_step "Installing chezmoi..."
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
        export PATH="$HOME/.local/bin:$PATH"
    fi
}

install_dependencies_fedora() {
    print_step "Installing dependencies for Fedora..."

    sudo dnf install -y git curl wget

    # Install chezmoi
    if ! command_exists chezmoi; then
        print_step "Installing chezmoi..."
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
        export PATH="$HOME/.local/bin:$PATH"
    fi
}

install_dependencies_arch() {
    print_step "Installing dependencies for Arch Linux..."

    sudo pacman -Syu --noconfirm git curl wget

    # Install chezmoi
    if ! command_exists chezmoi; then
        print_step "Installing chezmoi..."
        sudo pacman -S --noconfirm chezmoi
    fi
}

install_dependencies_opensuse() {
    print_step "Installing dependencies for openSUSE..."

    sudo zypper refresh
    sudo zypper install -y git curl wget

    # Install chezmoi
    if ! command_exists chezmoi; then
        print_step "Installing chezmoi..."
        sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
        export PATH="$HOME/.local/bin:$PATH"
    fi
}

install_dependencies() {
    local distro
    distro=$(detect_distro)

    print_step "Detected distribution: $distro"
    echo ""

    case "$distro" in
        ubuntu|debian|pop|linuxmint)
            install_dependencies_debian
            ;;
        fedora|rhel|centos)
            install_dependencies_fedora
            ;;
        arch|manjaro|endeavouros)
            install_dependencies_arch
            ;;
        opensuse|opensuse-tumbleweed|opensuse-leap|suse)
            install_dependencies_opensuse
            ;;
        *)
            print_warning "Unsupported distribution: $distro"
            print_warning "Attempting generic installation..."

            # Try to install chezmoi using the universal installer
            if ! command_exists chezmoi; then
                sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
                export PATH="$HOME/.local/bin:$PATH"
            fi
            ;;
    esac

    # Verify installations
    echo ""
    local packages=("git" "curl" "chezmoi")
    local missing_packages=()

    for package in "${packages[@]}"; do
        if command_exists "$package"; then
            print_success "$package is installed"
        else
            print_error "$package is not installed"
            missing_packages+=("$package")
        fi
    done

    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        print_error "Some packages are missing: ${missing_packages[*]}"
        print_warning "Please install them manually"
        exit 1
    fi
}

initialize_chezmoi() {
    print_step "Initializing chezmoi with dotfiles..."

    # Ensure chezmoi is in PATH
    if ! command_exists chezmoi; then
        export PATH="$HOME/.local/bin:$PATH"
    fi

    if ! command_exists chezmoi; then
        print_error "chezmoi is not available"
        return 1
    fi

    if chezmoi init --apply "$DOTFILES_REPO"; then
        print_success "Dotfiles initialized successfully"
        echo ""
        echo -e "${GREEN}Your dotfiles have been applied!${NC}"
        echo -e "${CYAN}Location: $HOME/.local/share/chezmoi${NC}"
    else
        print_warning "Chezmoi initialization completed with warnings"
        echo "You can manually run: chezmoi init --apply $DOTFILES_REPO"
    fi
}

#endregion

#region Main Installation

main() {
    clear
    print_banner

    # Check Linux
    if [[ "$(uname)" != "Linux" ]]; then
        print_error "This script is for Linux only"
        exit 1
    fi
    print_success "Running on Linux"
    echo ""

    # Check sudo
    check_sudo
    echo ""

    # Install dependencies
    install_dependencies
    echo ""

    # Initialize chezmoi
    if [[ "$SKIP_CHEZMOI" != "true" ]]; then
        initialize_chezmoi
    else
        print_warning "Skipping chezmoi initialization (SKIP_CHEZMOI=true)"
        echo "Run manually: chezmoi init --apply $DOTFILES_REPO"
    fi

    echo ""
    echo -e "${GREEN}========================================"
    echo "  Installation completed successfully!"
    echo "========================================${NC}"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo "  1. Restart your terminal to load new environment"
    echo "  2. Additional packages can be installed via your package manager"
    echo "  3. Edit dotfiles: chezmoi edit <file>"
    echo "  4. Apply changes: chezmoi apply"
    echo ""
}

# Run main installation
main "$@"

#endregion
