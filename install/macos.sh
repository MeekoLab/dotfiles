#!/usr/bin/env bash
#
# macOS dotfiles installer for MeekoLab
# Run: curl -fsLS https://raw.githubusercontent.com/MeekoLab/dotfiles/main/install/macos.sh | bash
#
# Author: MeekoLab
# Requires: macOS 10.15+ (Catalina or later)

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

check_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This script is for macOS only"
        exit 1
    fi
    print_success "Running on macOS"
}

install_xcode_tools() {
    print_step "Checking Xcode Command Line Tools..."

    if xcode-select -p &>/dev/null; then
        print_success "Xcode Command Line Tools already installed"
        return
    fi

    print_step "Installing Xcode Command Line Tools..."
    xcode-select --install

    # Wait for installation to complete
    echo "Please complete the Xcode Command Line Tools installation in the dialog..."
    until xcode-select -p &>/dev/null; do
        sleep 5
    done

    print_success "Xcode Command Line Tools installed"
}

install_homebrew() {
    print_step "Checking Homebrew installation..."

    if command_exists brew; then
        print_success "Homebrew already installed"
        return
    fi

    print_step "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    print_success "Homebrew installed successfully"
}

install_dependencies() {
    print_step "Installing essential dependencies..."
    echo ""

    local packages=("git" "curl" "chezmoi")
    local failed_packages=()

    for package in "${packages[@]}"; do
        if command_exists "$package"; then
            print_success "$package is already installed"
        else
            print_step "Installing $package..."
            if brew install "$package"; then
                print_success "$package installed successfully"
            else
                print_error "Failed to install $package"
                failed_packages+=("$package")
            fi
        fi
    done

    echo ""

    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        print_warning "Some packages failed to install: ${failed_packages[*]}"
        print_warning "You may need to install them manually"
    fi
}

initialize_chezmoi() {
    print_step "Initializing chezmoi with dotfiles..."

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

    # Check if running on macOS
    check_macos
    echo ""

    # Install Xcode Command Line Tools
    install_xcode_tools
    echo ""

    # Install Homebrew
    install_homebrew
    echo ""

    # Install dependencies
    install_dependencies

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
    echo "  2. Additional packages can be installed via Homebrew"
    echo "  3. Edit dotfiles: chezmoi edit <file>"
    echo "  4. Apply changes: chezmoi apply"
    echo ""
}

# Run main installation
main "$@"

#endregion
