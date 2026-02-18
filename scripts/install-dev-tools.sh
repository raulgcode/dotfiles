#!/bin/bash

#===============================================================================
# Development Tools Installation
#===============================================================================

install_python() {
    print_step "Installing Python..."
    
    install_formula "python@3.12"
    install_formula "python@3.11"
    
    # Create symlinks to ensure python3 is available
    if ! command_exists python3; then
        brew link python@3.12 2>/dev/null || true
    fi
    
    # Upgrade pip
    if command_exists python3; then
        print_step "Upgrading pip..."
        python3 -m pip install --upgrade pip --break-system-packages 2>/dev/null || \
        python3 -m pip install --upgrade pip 2>/dev/null || \
        print_warning "Could not upgrade pip"
        
        print_success "Python installed: $(python3 --version 2>/dev/null || echo 'version unknown')"
    else
        print_warning "Python3 not available after installation"
        add_failure "Python" "python3 command not available"
    fi
}

install_nvm() {
    print_step "Installing nvm (Node Version Manager)..."
    
    # Install nvm
    if [[ -d "$HOME/.nvm" ]]; then
        print_success "nvm is already installed"
        add_skipped "nvm" "Already installed"
    else
        if curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash; then
            print_success "nvm installed"
            add_success "nvm"
        else
            print_error "Failed to install nvm"
            add_failure "nvm" "Installation script failed"
            return 1
        fi
    fi
    
    # Load nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Install latest LTS Node.js
    if command_exists nvm; then
        print_step "Installing latest Node.js LTS..."
        if nvm install --lts; then
            nvm use --lts 2>/dev/null || true
            nvm alias default 'lts/*' 2>/dev/null || true
            print_success "Node.js installed: $(node --version 2>/dev/null || echo 'version unknown')"
            print_success "npm installed: $(npm --version 2>/dev/null || echo 'version unknown')"
            add_success "Node.js LTS"
        else
            print_error "Failed to install Node.js"
            add_failure "Node.js" "nvm install failed"
        fi
    else
        print_warning "nvm not available, skipping Node.js installation"
    fi
}

install_gh_cli() {
    print_step "Installing GitHub CLI..."
    
    install_formula "gh"
    
    if command_exists gh; then
        print_success "GitHub CLI installed: $(gh --version 2>/dev/null | head -n1 || echo 'version unknown')"
        print_info "Run 'gh auth login' to authenticate"
    fi
}

install_git() {
    print_step "Installing/Updating Git..."
    
    install_formula "git"
    
    if command_exists git; then
        print_success "Git installed: $(git --version 2>/dev/null || echo 'version unknown')"
    fi
}

install_additional_tools() {
    print_step "Installing additional development tools..."
    
    # Useful CLI tools
    install_formula "jq"           # JSON processor
    install_formula "wget"         # File downloader
    install_formula "tree"         # Directory tree viewer
    install_formula "htop"         # Process viewer
    install_formula "tldr"         # Simplified man pages
    
    print_success "Additional tools installation completed"
}

# Run installations
install_python
install_nvm
install_gh_cli
install_git
install_additional_tools
