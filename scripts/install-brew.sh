#!/bin/bash

#===============================================================================
# Homebrew Installation
#===============================================================================

install_homebrew() {
    if command_exists brew; then
        print_success "Homebrew is already installed"
        add_skipped "Homebrew" "Already installed"
        print_step "Updating Homebrew..."
        brew update || print_warning "Homebrew update encountered warnings"
        return 0
    fi

    print_step "Installing Homebrew..."
    print_info "This requires your password for sudo access"
    
    # Install Homebrew in non-interactive mode
    # NONINTERACTIVE=1 skips the "Press RETURN to continue" prompt
    if NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            # Intel Macs
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        print_success "Homebrew installed"
        add_success "Homebrew"
    else
        print_error "Failed to install Homebrew"
        add_failure "Homebrew" "Installation script failed"
        return 1
    fi
}

configure_homebrew() {
    if ! command_exists brew; then
        print_warning "Homebrew not available, skipping configuration"
        return 1
    fi
    
    print_step "Configuring Homebrew..."
    
    # Disable analytics
    brew analytics off 2>/dev/null || true
    
    # Update and check for outdated packages
    print_step "Checking for outdated packages..."
    brew update 2>/dev/null || true
    
    print_success "Homebrew configured"
}

# Run installation
install_homebrew
configure_homebrew
