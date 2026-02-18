#!/bin/bash

#===============================================================================
# Application Installation via Homebrew Cask
#===============================================================================

_APPS_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BREWFILE="$_APPS_SCRIPT_DIR/../configs/Brewfile"

install_applications() {
    print_step "Installing applications via Homebrew..."
    
    # Core applications (always install)
    install_cask "google-chrome"
    install_cask "visual-studio-code"
    install_cask "docker"
    install_cask "postman"
    
    # Additional apps from Brewfile (if configured)
    if [[ -f "$BREWFILE" ]]; then
        print_step "Installing additional applications from Brewfile..."
        
        # Parse casks from Brewfile (excluding comments)
        while IFS= read -r line || [[ -n "$line" ]]; do
            # Match cask declarations (not commented)
            if [[ "$line" =~ ^cask[[:space:]]+\"([^\"]+)\" ]]; then
                local cask="${BASH_REMATCH[1]}"
                # Skip core apps already installed above
                case "$cask" in
                    google-chrome|visual-studio-code|docker|postman)
                        continue
                        ;;
                    *)
                        install_cask "$cask"
                        ;;
                esac
            fi
        done < "$BREWFILE"
    fi
    
    print_success "Application installation completed"
}

set_default_browser() {
    print_step "Setting Chrome as default browser..."
    
    # Check if defaultbrowser is available, if not install it
    if ! command_exists defaultbrowser; then
        if brew install defaultbrowser 2>&1; then
            print_success "defaultbrowser tool installed"
        else
            print_warning "Could not install defaultbrowser tool"
            add_failure "defaultbrowser" "Installation failed"
            return 1
        fi
    fi
    
    # Set Chrome as default
    if defaultbrowser chrome 2>/dev/null; then
        print_success "Chrome set as default browser"
    else
        print_warning "Could not set Chrome as default browser automatically"
        print_info "You may need to set it manually in System Preferences > Default Web Browser"
    fi
}

start_docker() {
    print_step "Starting Docker Desktop..."
    
    if app_installed "Docker"; then
        open -a Docker 2>/dev/null || true
        print_success "Docker Desktop started"
        print_info "Please complete Docker Desktop setup when prompted"
    else
        print_warning "Docker Desktop not found, skipping startup"
    fi
}

# Run installation
install_applications
set_default_browser
start_docker
