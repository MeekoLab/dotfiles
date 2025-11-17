#!/usr/bin/env bash
#
# Install Git hooks for automatic versioning
# This script runs once after chezmoi applies dotfiles
#
# Author: MeekoLab

set -euo pipefail

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly RED='\033[0;31m'
readonly NC='\033[0m' # No Color

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

# Find the dotfiles repository root
# This script is run from chezmoi, so we need to find the source directory
DOTFILES_SOURCE="${DOTFILES_DIR:-$HOME/.local/share/chezmoi}"

if [[ ! -d "$DOTFILES_SOURCE" ]]; then
    # Try alternative locations
    if [[ -d "$HOME/.dotfiles" ]]; then
        DOTFILES_SOURCE="$HOME/.dotfiles"
    else
        print_error "Cannot find dotfiles source directory"
        exit 1
    fi
fi

GIT_HOOKS_SOURCE="$DOTFILES_SOURCE/git-hooks"
GIT_HOOKS_DEST="$DOTFILES_SOURCE/.git/hooks"

print_step "Installing Git hooks for automatic versioning..."

# Check if we're in a git repository
if [[ ! -d "$DOTFILES_SOURCE/.git" ]]; then
    print_warning "Not a git repository, skipping git hooks installation"
    exit 0
fi

# Check if git-hooks directory exists
if [[ ! -d "$GIT_HOOKS_SOURCE" ]]; then
    print_warning "git-hooks directory not found at $GIT_HOOKS_SOURCE"
    exit 0
fi

# Create hooks directory if it doesn't exist
mkdir -p "$GIT_HOOKS_DEST"

# Install each hook
installed_count=0
for hook in "$GIT_HOOKS_SOURCE"/*; do
    if [[ -f "$hook" ]]; then
        hook_name=$(basename "$hook")
        dest_hook="$GIT_HOOKS_DEST/$hook_name"

        # Copy hook
        cp "$hook" "$dest_hook"
        chmod +x "$dest_hook"

        print_success "Installed hook: $hook_name"
        installed_count=$((installed_count + 1))
    fi
done

if [[ $installed_count -eq 0 ]]; then
    print_warning "No git hooks found to install"
else
    echo ""
    print_success "Git hooks installed successfully! ($installed_count hook(s))"
    echo ""
    echo -e "${CYAN}Automatic versioning enabled:${NC}"
    echo "  • Version will auto-increment on 'git push'"
    echo "  • Current version: $(cat "$DOTFILES_SOURCE/VERSION" 2>/dev/null || echo 'not found')"
    echo "  • To manually bump version: edit VERSION file"
    echo ""
fi

exit 0
