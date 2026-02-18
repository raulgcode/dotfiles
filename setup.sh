#!/bin/bash

#===============================================================================
#
#   macOS Setup Script
#   Author: Raul Gonzalez
#   Description: Automated macOS development environment setup
#
#   Usage:
#     curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/dotfiles/main/setup.sh | bash
#
#   Or clone and run locally:
#     git clone https://github.com/YOUR_USERNAME/dotfiles.git
#     cd dotfiles && ./setup.sh
#
#===============================================================================

# Don't exit on error - we handle errors gracefully and continue
set +e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# If running via curl, clone the repo first
if [[ ! -d "$SCRIPT_DIR/scripts" ]]; then
    echo -e "${CYAN}Downloading dotfiles...${NC}"
    TEMP_DIR=$(mktemp -d)
    git clone --depth 1 https://github.com/YOUR_USERNAME/dotfiles.git "$TEMP_DIR"
    cd "$TEMP_DIR"
    SCRIPT_DIR="$TEMP_DIR"
fi

#===============================================================================
# Helper Functions
#===============================================================================

print_header() {
    echo ""
    echo -e "${PURPLE}============================================================${NC}"
    echo -e "${PURPLE}  $1${NC}"
    echo -e "${PURPLE}============================================================${NC}"
    echo ""
}

print_step() {
    echo -e "${CYAN}➜ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

command_exists() {
    command -v "$1" &> /dev/null
}

#===============================================================================
# Main Setup
#===============================================================================

main() {
    print_header "macOS Development Environment Setup"
    
    echo -e "${BLUE}This script will install and configure:${NC}"
    echo "  • Xcode Command Line Tools"
    echo "  • Homebrew"
    echo "  • Applications (Chrome, VS Code, Docker, Postman)"
    echo "  • Development tools (Python, Node.js via nvm, gh CLI)"
    echo "  • VS Code extensions"
    echo "  • ZSH plugins (autosuggestions, syntax-highlighting)"
    echo ""
    
    read -p "Press Enter to continue or Ctrl+C to cancel..."

    # Source utility functions
    source "$SCRIPT_DIR/scripts/utils.sh"

    # Run installation scripts in order
    print_header "Installing Xcode Command Line Tools"
    source "$SCRIPT_DIR/scripts/install-xcode.sh"

    print_header "Installing Homebrew"
    source "$SCRIPT_DIR/scripts/install-brew.sh"

    print_header "Installing Applications"
    source "$SCRIPT_DIR/scripts/install-apps.sh"

    print_header "Installing Development Tools"
    source "$SCRIPT_DIR/scripts/install-dev-tools.sh"

    print_header "Configuring VS Code"
    source "$SCRIPT_DIR/scripts/install-vscode.sh"

    print_header "Configuring ZSH Plugins"
    source "$SCRIPT_DIR/scripts/install-zsh-plugins.sh"

    print_header "Applying macOS Settings"
    source "$SCRIPT_DIR/scripts/configure-macos.sh"

    # Print installation report
    print_installation_report

    # Final summary
    print_header "Setup Complete!"
    
    echo -e "${GREEN}Your macOS development environment is ready!${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo "  1. Restart your terminal or run: source ~/.zshrc"
    echo "  2. Open VS Code and sign in to sync settings"
    echo "  3. Open Docker Desktop and complete setup"
    echo "  4. Run 'gh auth login' to authenticate with GitHub"
    echo ""
    
    # Show warning if there were failures
    if [[ ${#FAILED_INSTALLATIONS[@]} -gt 0 ]]; then
        echo -e "${YELLOW}Note: Some installations failed. Review the report above.${NC}"
        echo ""
    fi
    
    print_success "Enjoy your new development setup! 🚀"
}

# Run main function
main "$@"
