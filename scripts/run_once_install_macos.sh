#!/usr/bin/env bash
#
# Chezmoi post-install script for macOS applications
# Automatically executed by chezmoi after applying dotfiles on macOS
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

check_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This script is for macOS only"
        return 1
    fi
    print_success "Running on macOS"
    return 0
}

check_homebrew() {
    if ! command_exists brew; then
        print_error "Homebrew is not installed"
        print_warning "Please install Homebrew first: https://brew.sh"
        return 1
    fi
    print_success "Homebrew is installed"
    return 0
}

install_formula() {
    local formula="$1"
    local description="$2"

    print_step "Installing $description..."

    # Check if already installed
    if brew list "$formula" &>/dev/null; then
        print_success "$description is already installed"
        return 0
    fi

    # Install formula
    if brew install "$formula" &>/dev/null; then
        print_success "$description installed successfully"
        return 0
    else
        print_error "Failed to install $description"
        return 1
    fi
}

install_cask() {
    local cask="$1"
    local description="$2"

    print_step "Installing $description..."

    # Check if already installed
    if brew list --cask "$cask" &>/dev/null; then
        print_success "$description is already installed"
        return 0
    fi

    # Install cask
    if brew install --cask "$cask" &>/dev/null; then
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
    print_step "Starting macOS application installation..."
    echo ""

    # Check if running on macOS
    if ! check_macos; then
        exit 1
    fi

    # Check if Homebrew is installed
    if ! check_homebrew; then
        exit 1
    fi

    # Update Homebrew
    print_step "Updating Homebrew..."
    brew update &>/dev/null
    print_success "Homebrew updated"

    # Track results
    local -a success_packages=()
    local -a failed_packages=()

    # ========================================================================
    # Homebrew Formulae (CLI Tools)
    # ========================================================================

    print_category "CLI Tools"

    local -a formulae=(
        "wget:wget"
        "tree:Tree (directory listing)"
        "htop:htop (process viewer)"
        "neofetch:Neofetch (system info)"
        "starship:Starship (cross-shell prompt)"
        "jq:jq (JSON processor)"
        "fzf:fzf (fuzzy finder)"
        "ripgrep:ripgrep (faster grep)"
        "fd:fd (faster find)"
        "bat:bat (cat with syntax highlighting)"
        "exa:exa (modern ls replacement)"
        "tldr:tldr (simplified man pages)"
        "tmux:tmux (terminal multiplexer)"
        "neovim:Neovim (modern Vim)"
    )

    for formula_pair in "${formulae[@]}"; do
        IFS=':' read -r formula description <<< "$formula_pair"
        if install_formula "$formula" "$description"; then
            success_packages+=("$description")
        else
            failed_packages+=("$description")
        fi
    done

    # Git Tools
    print_category "Git Tools"

    local -a git_tools=(
        "git-delta:Delta (better git diffs)"
        "lazygit:LazyGit (terminal UI for git)"
        "gh:GitHub CLI"
    )

    for formula_pair in "${git_tools[@]}"; do
        IFS=':' read -r formula description <<< "$formula_pair"
        if install_formula "$formula" "$description"; then
            success_packages+=("$description")
        else
            failed_packages+=("$description")
        fi
    done

    # Development Tools
    print_category "Development Tools"

    local -a dev_tools=(
        "node:Node.js"
        "python@3:Python 3"
        "go:Go"
        "rust:Rust"
        "deno:Deno"
    )

    for formula_pair in "${dev_tools[@]}"; do
        IFS=':' read -r formula description <<< "$formula_pair"
        if install_formula "$formula" "$description"; then
            success_packages+=("$description")
        else
            failed_packages+=("$description")
        fi
    done

    # ========================================================================
    # Homebrew Casks (GUI Applications)
    # ========================================================================

    print_category "Applications"

    local -a casks=(
        "visual-studio-code:Visual Studio Code"
        "iterm2:iTerm2"
        "ghostty:Ghostty (GPU-accelerated terminal)"
        "google-chrome:Google Chrome"
        "firefox:Firefox"
        "discord:Discord"
        "telegram:Telegram"
        "spotify:Spotify"
        "vlc:VLC Media Player"
        "notion:Notion"
        "docker:Docker Desktop"
    )

    for cask_pair in "${casks[@]}"; do
        IFS=':' read -r cask description <<< "$cask_pair"
        if install_cask "$cask" "$description"; then
            success_packages+=("$description")
        else
            failed_packages+=("$description")
        fi
    done

    # Fonts
    print_category "Fonts"

    # Add font tap
    if ! brew tap | grep -q "homebrew/cask-fonts"; then
        print_step "Adding Homebrew fonts tap..."
        brew tap homebrew/cask-fonts &>/dev/null
        print_success "Fonts tap added"
    fi

    local -a fonts=(
        "font-fira-code-nerd-font:FiraCode Nerd Font"
        "font-jetbrains-mono-nerd-font:JetBrains Mono Nerd Font"
        "font-meslo-lg-nerd-font:Meslo Nerd Font"
    )

    for font_pair in "${fonts[@]}"; do
        IFS=':' read -r font description <<< "$font_pair"
        if install_cask "$font" "$description"; then
            success_packages+=("$description")
        else
            failed_packages+=("$description")
        fi
    done

    # ========================================================================
    # Post-Installation
    # ========================================================================

    print_category "Post-Installation"

    # Cleanup
    print_step "Cleaning up Homebrew..."
    brew cleanup &>/dev/null
    print_success "Cleanup complete"

    # ========================================================================
    # Summary
    # ========================================================================

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
    echo -e "${CYAN}Tip: Restart your terminal to use newly installed tools${NC}"
    echo ""

    # Exit with error code if there were failures
    if [[ ${#failed_packages[@]} -gt 0 ]]; then
        print_warning "Some packages failed to install. You may want to install them manually."
        exit 1
    fi
}

# Run main installation only on macOS
if [[ "$(uname)" == "Darwin" ]]; then
    main "$@"
else
    print_error "This script is for macOS only"
    exit 1
fi

#endregion
