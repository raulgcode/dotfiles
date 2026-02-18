#!/bin/bash

#===============================================================================
# ZSH Plugins Installation
#===============================================================================

install_zsh_plugins() {
    print_step "Installing ZSH plugins via Homebrew..."
    
    # Install plugins
    install_formula "zsh-autosuggestions"
    install_formula "zsh-syntax-highlighting"
    
    print_success "ZSH plugins installation completed"
}

configure_zsh() {
    print_step "Configuring ZSH..."
    
    local zshrc="$HOME/.zshrc"
    
    # Backup existing .zshrc
    backup_file "$zshrc"
    
    # Create .zshrc if it doesn't exist
    touch "$zshrc"
    
    # Add Homebrew to PATH (Apple Silicon)
    if [[ $(uname -m) == "arm64" ]]; then
        add_to_file 'eval "$(/opt/homebrew/bin/brew shellenv)"' "$zshrc"
    fi
    
    # Add zsh-autosuggestions
    local autosuggestions_path=""
    if [[ $(uname -m) == "arm64" ]]; then
        autosuggestions_path="/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    else
        autosuggestions_path="/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    fi
    
    if [[ -f "$autosuggestions_path" ]]; then
        add_to_file "" "$zshrc"
        add_to_file "# ZSH Autosuggestions" "$zshrc"
        add_to_file "source $autosuggestions_path" "$zshrc"
    else
        print_warning "zsh-autosuggestions not found at $autosuggestions_path"
    fi
    
    # Add zsh-syntax-highlighting (must be last)
    local syntax_path=""
    if [[ $(uname -m) == "arm64" ]]; then
        syntax_path="/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    else
        syntax_path="/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    fi
    
    if [[ -f "$syntax_path" ]]; then
        add_to_file "" "$zshrc"
        add_to_file "# ZSH Syntax Highlighting (must be at the end)" "$zshrc"
        add_to_file "source $syntax_path" "$zshrc"
    else
        print_warning "zsh-syntax-highlighting not found at $syntax_path"
    fi
    
    # Add nvm configuration
    add_to_file "" "$zshrc"
    add_to_file "# NVM Configuration" "$zshrc"
    add_to_file 'export NVM_DIR="$HOME/.nvm"' "$zshrc"
    add_to_file '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' "$zshrc"
    add_to_file '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' "$zshrc"
    
    # Add useful aliases
    add_to_file "" "$zshrc"
    add_to_file "# Aliases" "$zshrc"
    add_to_file "alias ll='ls -la'" "$zshrc"
    add_to_file "alias la='ls -A'" "$zshrc"
    add_to_file "alias l='ls -CF'" "$zshrc"
    add_to_file "alias gs='git status'" "$zshrc"
    add_to_file "alias gp='git pull'" "$zshrc"
    add_to_file "alias gc='git commit'" "$zshrc"
    add_to_file "alias gd='git diff'" "$zshrc"
    add_to_file "alias code.='code .'" "$zshrc"
    
        # Ensure NVM is loaded and add automatic .nvmrc switching
        if ! grep -q "load-nvmrc" "$zshrc" 2>/dev/null; then
                cat >> "$zshrc" <<'EOF'
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

autoload -U add-zsh-hook
load-nvmrc() {
    local node_version="$(nvm version 2>/dev/null)"
    local nvmrc_path="$(nvm_find_nvmrc 2>/dev/null)"

    if [ -n "$nvmrc_path" ]; then
        local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")" 2>/dev/null)

        if [ "$nvmrc_node_version" = "N/A" ]; then
            nvm install
        elif [ "$nvmrc_node_version" != "$node_version" ]; then
            nvm use
        fi
    elif [ "$node_version" != "$(nvm version default 2>/dev/null)" ]; then
        echo "Reverting to nvm default version"
        nvm use default
    fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOF
                print_info "Appended nvm auto-load block to $zshrc"
        else
                print_info "nvm auto-load block already present in $zshrc"
        fi

        print_success "ZSH configured"
        add_success "ZSH Configuration"
}

# Run installation
install_zsh_plugins
configure_zsh
