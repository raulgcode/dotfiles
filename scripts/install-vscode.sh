#!/bin/bash

#===============================================================================
# Visual Studio Code Configuration
#===============================================================================

_VSCODE_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTENSIONS_FILE="$_VSCODE_SCRIPT_DIR/../configs/vscode/extensions.txt"

install_code_cli() {
    # Check if code command is available
    if command_exists code; then
        print_success "VS Code CLI is available"
        return 0
    fi
    
    print_step "Setting up VS Code CLI..."
    
    # Add code to PATH
    local code_path="/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
    
    if [[ -d "$code_path" ]]; then
        export PATH="$PATH:$code_path"
        add_to_file "export PATH=\"\$PATH:$code_path\"" "$HOME/.zshrc"
        print_success "VS Code CLI added to PATH"
    else
        print_warning "VS Code path not found, extensions will be installed on first VS Code launch"
    fi
}

install_vscode_extensions() {
    print_step "Installing VS Code extensions..."
    
    local installed_count=0
    local failed_count=0
    local skipped_count=0
    
    if ! command_exists code; then
        print_warning "VS Code CLI not available"
        print_info "Extensions will need to be installed manually or after VS Code is fully set up"
        print_info "Extension list saved at: $EXTENSIONS_FILE"
        add_skipped "VS Code Extensions" "VS Code CLI not available"
        return 0
    fi
    
    # Get list of already installed extensions
    local installed_extensions
    installed_extensions=$(code --list-extensions 2>/dev/null | tr '[:upper:]' '[:lower:]')
    
    # Read extensions from file
    if [[ -f "$EXTENSIONS_FILE" ]]; then
        while IFS= read -r extension || [[ -n "$extension" ]]; do
            # Skip comments and empty lines
            [[ "$extension" =~ ^#.*$ ]] && continue
            [[ -z "${extension// }" ]] && continue
            
            # Trim whitespace
            extension=$(echo "$extension" | xargs)
            local ext_lower=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
            
            # Check if already installed
            if echo "$installed_extensions" | grep -q "^${ext_lower}$"; then
                print_success "$extension already installed"
                ((skipped_count++))
                continue
            fi
            
            # Install extension
            print_step "Installing extension: $extension"
            if code --install-extension "$extension" --force 2>&1; then
                print_success "$extension installed"
                ((installed_count++))
            else
                print_warning "Failed to install $extension"
                add_failure "VS Code: $extension" "Extension installation failed"
                ((failed_count++))
            fi
        done < "$EXTENSIONS_FILE"
        
        print_info "Extensions: $installed_count installed, $skipped_count skipped, $failed_count failed"
    else
        print_warning "Extensions file not found: $EXTENSIONS_FILE"
        add_failure "VS Code Extensions" "Extensions file not found"
    fi
    
    if [[ $installed_count -gt 0 ]]; then
        add_success "VS Code Extensions ($installed_count new)"
    fi
    
    print_success "VS Code extensions installation completed"
}

configure_vscode_settings() {
    print_step "Configuring VS Code settings..."
    
    local settings_dir="$HOME/Library/Application Support/Code/User"
    local settings_file="$settings_dir/settings.json"
    
    # Create directory if it doesn't exist
    mkdir -p "$settings_dir"
    
    # Only create default settings if file doesn't exist
    if [[ ! -f "$settings_file" ]]; then
        cat > "$settings_file" << 'EOF'
{
    "editor.fontSize": 14,
    "editor.fontFamily": "'JetBrains Mono', 'Fira Code', Menlo, Monaco, 'Courier New', monospace",
    "editor.fontLigatures": true,
    "editor.tabSize": 2,
    "editor.wordWrap": "on",
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "esbenp.prettier-vscode",
    "editor.minimap.enabled": false,
    "editor.bracketPairColorization.enabled": true,
    "editor.guides.bracketPairs": true,
    "editor.cursorBlinking": "smooth",
    "editor.cursorSmoothCaretAnimation": "on",
    "editor.smoothScrolling": true,
    "editor.linkedEditing": true,
    "editor.renderWhitespace": "selection",
    
    "files.autoSave": "afterDelay",
    "files.autoSaveDelay": 1000,
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    
    "terminal.integrated.fontSize": 13,
    "terminal.integrated.defaultProfile.osx": "zsh",
    
    "workbench.colorTheme": "Default Dark+",
    "workbench.iconTheme": "vs-seti",
    "workbench.startupEditor": "none",
    "workbench.editor.enablePreview": false,
    
    "git.autofetch": true,
    "git.confirmSync": false,
    
    "explorer.confirmDelete": false,
    "explorer.confirmDragAndDrop": false,
    
    "prettier.singleQuote": true,
    "prettier.semi": true,
    
    "[typescript]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[typescriptreact]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[javascript]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[javascriptreact]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[json]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[html]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    },
    "[css]": {
        "editor.defaultFormatter": "esbenp.prettier-vscode"
    }
}
EOF
        print_success "VS Code settings configured"
    else
        print_info "VS Code settings file already exists, skipping"
    fi
}

# Run configuration
install_code_cli
install_vscode_extensions
configure_vscode_settings
