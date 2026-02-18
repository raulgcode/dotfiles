#!/bin/bash

#===============================================================================
# Xcode Command Line Tools Installation
#===============================================================================

install_xcode_clt() {
    if xcode-select -p &> /dev/null; then
        print_success "Xcode Command Line Tools already installed"
        add_skipped "Xcode Command Line Tools" "Already installed"
        return 0
    fi

    print_step "Installing Xcode Command Line Tools..."
    
    # Install Xcode Command Line Tools
    xcode-select --install 2>&1 || true
    
    # Wait for installation to complete
    print_info "Waiting for Xcode Command Line Tools installation..."
    print_info "Please complete the installation dialog if prompted"
    
    # Wait up to 30 minutes for installation
    local timeout=1800
    local waited=0
    
    until xcode-select -p &> /dev/null; do
        sleep 5
        ((waited+=5))
        if [[ $waited -ge $timeout ]]; then
            print_error "Xcode Command Line Tools installation timed out"
            add_failure "Xcode Command Line Tools" "Installation timed out"
            return 1
        fi
    done
    
    print_success "Xcode Command Line Tools installed"
    add_success "Xcode Command Line Tools"
}

# Run installation
install_xcode_clt
