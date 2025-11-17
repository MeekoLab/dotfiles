#!/usr/bin/env bash
#
# Chezmoi post-install script for development tools
# Installs: nvm (Node.js), pyenv (Python), rustup (Rust), Oh My Zsh
# Automatically executed by chezmoi after applying dotfiles
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

#endregion

#region Main Installation

main() {
    print_step "Starting development tools installation..."
    echo ""

    # Skip on Windows
    if [[ "$(uname)" == "MINGW"* ]] || [[ "$(uname)" == "MSYS"* ]]; then
        print_warning "Skipping on Windows (use WSL for these tools)"
        exit 0
    fi

    # ========================================================================
    # Starship Prompt
    # ========================================================================

    print_category "Shell Enhancement"

    if ! command_exists starship; then
        print_step "Installing Starship prompt..."
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        print_success "Starship installed"
    else
        print_success "Starship is already installed"
    fi

    # ========================================================================
    # Oh My Zsh
    # ========================================================================

    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        print_step "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh installed"

        # Install popular plugins
        print_step "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" || true

        print_step "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" || true

        print_success "Zsh plugins installed"
    else
        print_success "Oh My Zsh is already installed"
    fi

    # ========================================================================
    # Node.js (nvm)
    # ========================================================================

    print_category "Node.js (nvm)"

    if [ ! -d "$HOME/.nvm" ]; then
        print_step "Installing nvm..."

        # Install nvm
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

        # Load nvm
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

        print_success "nvm installed"

        # Install latest LTS Node.js
        if command_exists nvm; then
            print_step "Installing Node.js LTS..."
            nvm install --lts
            nvm use --lts
            nvm alias default 'lts/*'
            print_success "Node.js LTS installed"

            # Install useful global packages
            print_step "Installing global npm packages..."
            npm install -g yarn pnpm typescript ts-node nodemon
            print_success "Global npm packages installed"
        fi
    else
        print_success "nvm is already installed"
    fi

    # ========================================================================
    # Python (pyenv)
    # ========================================================================

    print_category "Python (pyenv)"

    if [ ! -d "$HOME/.pyenv" ]; then
        print_step "Installing pyenv..."

        # Install pyenv
        curl https://pyenv.run | bash

        # Load pyenv
        export PYENV_ROOT="$HOME/.pyenv"
        export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"

        print_success "pyenv installed"

        # Install latest Python
        if command_exists pyenv; then
            print_step "Installing latest Python..."
            LATEST_PYTHON=$(pyenv install --list | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | xargs)
            pyenv install "$LATEST_PYTHON"
            pyenv global "$LATEST_PYTHON"
            print_success "Python $LATEST_PYTHON installed"

            # Install useful packages
            print_step "Installing Python packages..."
            pip install --upgrade pip
            pip install virtualenv poetry pipenv black flake8 mypy pytest ipython
            print_success "Python packages installed"
        fi
    else
        print_success "pyenv is already installed"
    fi

    # ========================================================================
    # Rust (rustup)
    # ========================================================================

    print_category "Rust (rustup)"

    if ! command_exists rustc; then
        print_step "Installing Rust..."

        # Install Rust
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

        # Load Rust
        source "$HOME/.cargo/env"

        print_success "Rust installed"

        # Install common tools
        if command_exists cargo; then
            print_step "Installing Rust tools..."
            cargo install cargo-edit cargo-watch cargo-tree
            print_success "Rust tools installed"
        fi
    else
        print_success "Rust is already installed"
    fi

    # ========================================================================
    # Summary
    # ========================================================================

    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}          Installation Summary           ${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    echo -e "${GREEN}✓ Development tools installed:${NC}"
    [ -d "$HOME/.oh-my-zsh" ] && echo "  - Oh My Zsh"
    [ -d "$HOME/.nvm" ] && echo "  - nvm (Node.js)"
    [ -d "$HOME/.pyenv" ] && echo "  - pyenv (Python)"
    command_exists rustc && echo "  - Rust"

    echo ""
    echo -e "${YELLOW}⚠ Important:${NC}"
    echo "  1. Restart your terminal or run: exec \$SHELL"
    echo "  2. Check installed versions:"
    echo "     - node --version"
    echo "     - python --version"
    echo "     - rustc --version"
    echo ""
}

# Run main installation
main "$@"

#endregion
