#!/bin/bash

#===============================================================================
# Utility Functions
# Shared helper functions for all installation scripts
#===============================================================================

# Colors (if not already defined)
RED=${RED:-'\033[0;31m'}
GREEN=${GREEN:-'\033[0;32m'}
YELLOW=${YELLOW:-'\033[0;33m'}
BLUE=${BLUE:-'\033[0;34m'}
PURPLE=${PURPLE:-'\033[0;35m'}
CYAN=${CYAN:-'\033[0;36m'}
NC=${NC:-'\033[0m'}

#===============================================================================
# Error Tracking
#===============================================================================

# Arrays to track installation results
declare -a FAILED_INSTALLATIONS=()
declare -a SKIPPED_INSTALLATIONS=()
declare -a SUCCESSFUL_INSTALLATIONS=()
declare -a UPGRADED_INSTALLATIONS=()

# Add to failed list
add_failure() {
    local name="$1"
    local reason="${2:-Unknown error}"
    FAILED_INSTALLATIONS+=("$name: $reason")
}

# Add to success list
add_success() {
    local name="$1"
    SUCCESSFUL_INSTALLATIONS+=("$name")
}

# Add to skipped list
add_skipped() {
    local name="$1"
    local reason="${2:-Already installed}"
    SKIPPED_INSTALLATIONS+=("$name: $reason")
}

# Add to upgraded list
add_upgraded() {
    local name="$1"
    local from_version="$2"
    local to_version="$3"
    UPGRADED_INSTALLATIONS+=("$name: $from_version → $to_version")
}

# Print final report
print_installation_report() {
    echo ""
    echo -e "${PURPLE}============================================================${NC}"
    echo -e "${PURPLE}  Installation Report${NC}"
    echo -e "${PURPLE}============================================================${NC}"
    echo ""
    
    # Successful installations
    if [[ ${#SUCCESSFUL_INSTALLATIONS[@]} -gt 0 ]]; then
        echo -e "${GREEN}✓ Successfully Installed (${#SUCCESSFUL_INSTALLATIONS[@]}):${NC}"
        for item in "${SUCCESSFUL_INSTALLATIONS[@]}"; do
            echo -e "  ${GREEN}•${NC} $item"
        done
        echo ""
    fi
    
    # Upgraded installations
    if [[ ${#UPGRADED_INSTALLATIONS[@]} -gt 0 ]]; then
        echo -e "${BLUE}↑ Upgraded (${#UPGRADED_INSTALLATIONS[@]}):${NC}"
        for item in "${UPGRADED_INSTALLATIONS[@]}"; do
            echo -e "  ${BLUE}•${NC} $item"
        done
        echo ""
    fi
    
    # Skipped installations (already up to date)
    if [[ ${#SKIPPED_INSTALLATIONS[@]} -gt 0 ]]; then
        echo -e "${YELLOW}⊘ Skipped (${#SKIPPED_INSTALLATIONS[@]}):${NC}"
        for item in "${SKIPPED_INSTALLATIONS[@]}"; do
            echo -e "  ${YELLOW}•${NC} $item"
        done
        echo ""
    fi
    
    # Failed installations
    if [[ ${#FAILED_INSTALLATIONS[@]} -gt 0 ]]; then
        echo -e "${RED}✗ Failed (${#FAILED_INSTALLATIONS[@]}):${NC}"
        for item in "${FAILED_INSTALLATIONS[@]}"; do
            echo -e "  ${RED}•${NC} $item"
        done
        echo ""
        echo -e "${RED}Some installations failed. Please review the errors above.${NC}"
    else
        echo -e "${GREEN}All installations completed without errors!${NC}"
    fi
    echo ""
}

# Print functions
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

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Check if an app is installed (macOS)
app_installed() {
    local app_name="$1"
    [[ -d "/Applications/$app_name.app" ]] || [[ -d "$HOME/Applications/$app_name.app" ]]
}

# Check if a brew cask is installed
cask_installed() {
    brew list --cask "$1" &> /dev/null
}

# Check if a brew formula is installed
formula_installed() {
    brew list "$1" &> /dev/null
}

# Check if formula needs upgrade
formula_outdated() {
    local formula="$1"
    brew outdated --formula | grep -q "^${formula}$\|^${formula}@"
}

# Check if cask needs upgrade
cask_outdated() {
    local cask="$1"
    brew outdated --cask | grep -q "^${cask}$"
}

# Get installed version of formula
get_formula_version() {
    local formula="$1"
    brew list --versions "$formula" 2>/dev/null | awk '{print $2}'
}

# Get installed version of cask
get_cask_version() {
    local cask="$1"
    brew list --cask --versions "$cask" 2>/dev/null | awk '{print $2}'
}

# Install or upgrade brew formula
install_formula() {
    local formula="$1"
    local old_version=""
    local new_version=""
    
    if formula_installed "$formula"; then
        old_version=$(get_formula_version "$formula")
        
        # Check if upgrade is available
        if formula_outdated "$formula"; then
            print_step "Upgrading $formula ($old_version)..."
            if brew upgrade "$formula" 2>&1; then
                new_version=$(get_formula_version "$formula")
                print_success "$formula upgraded"
                add_upgraded "$formula" "$old_version" "$new_version"
            else
                print_error "Failed to upgrade $formula"
                add_failure "$formula" "Upgrade failed"
            fi
        else
            print_success "$formula is already installed and up to date ($old_version)"
            add_skipped "$formula" "Up to date ($old_version)"
        fi
    else
        print_step "Installing $formula..."
        if brew install "$formula" 2>&1; then
            new_version=$(get_formula_version "$formula")
            print_success "$formula installed ($new_version)"
            add_success "$formula"
        else
            print_error "Failed to install $formula"
            add_failure "$formula" "Installation failed"
        fi
    fi
}

# Map cask names to application names (for apps installed outside Homebrew)
get_app_name_for_cask() {
    local cask="$1"
    case "$cask" in
        google-chrome) echo "Google Chrome" ;;
        visual-studio-code) echo "Visual Studio Code" ;;
        docker) echo "Docker" ;;
        postman) echo "Postman" ;;
        discord) echo "Discord" ;;
        firefox) echo "Firefox" ;;
        iterm2) echo "iTerm" ;;
        warp) echo "Warp" ;;
        slack) echo "Slack" ;;
        spotify) echo "Spotify" ;;
        zoom) echo "zoom.us" ;;
        notion) echo "Notion" ;;
        obsidian) echo "Obsidian" ;;
        rectangle) echo "Rectangle" ;;
        brave-browser) echo "Brave Browser" ;;
        arc) echo "Arc" ;;
        figma) echo "Figma" ;;
        *) echo "" ;;
    esac
}

# Install or upgrade brew cask
install_cask() {
    local cask="$1"
    local old_version=""
    local new_version=""
    local app_name=""
    
    # First check if installed via Homebrew
    if cask_installed "$cask"; then
        old_version=$(get_cask_version "$cask")
        
        # Check if upgrade is available
        if cask_outdated "$cask"; then
            print_step "Upgrading $cask ($old_version)..."
            if brew upgrade --cask "$cask" 2>&1; then
                new_version=$(get_cask_version "$cask")
                print_success "$cask upgraded"
                add_upgraded "$cask" "$old_version" "$new_version"
            else
                print_error "Failed to upgrade $cask"
                add_failure "$cask" "Upgrade failed"
            fi
        else
            print_success "$cask is already installed and up to date ($old_version)"
            add_skipped "$cask" "Up to date ($old_version)"
        fi
        return 0
    fi
    
    # Check if app is installed outside of Homebrew (e.g., manually or via App Store)
    app_name=$(get_app_name_for_cask "$cask")
    if [[ -n "$app_name" ]] && app_installed "$app_name"; then
        print_success "$cask is already installed (found as $app_name.app)"
        add_skipped "$cask" "Already installed (non-Homebrew)"
        return 0
    fi
    
    # Not installed, proceed with installation
    print_step "Installing $cask..."
    if brew install --cask "$cask" 2>&1; then
        new_version=$(get_cask_version "$cask")
        print_success "$cask installed ($new_version)"
        add_success "$cask"
    else
        # Check again if the app exists now (might have been installed during attempt)
        if [[ -n "$app_name" ]] && app_installed "$app_name"; then
            print_success "$cask is already installed (found as $app_name.app)"
            add_skipped "$cask" "Already installed (non-Homebrew)"
        else
            print_error "Failed to install $cask"
            add_failure "$cask" "Installation failed"
        fi
    fi
}

# Safe execution wrapper - runs command and continues on failure
safe_exec() {
    local description="$1"
    shift
    
    print_step "$description..."
    if "$@" 2>&1; then
        print_success "$description completed"
        return 0
    else
        print_error "$description failed"
        add_failure "$description" "Command failed: $*"
        return 1
    fi
}

# Add line to file if not present
add_to_file() {
    local line="$1"
    local file="$2"
    
    if ! grep -qF "$line" "$file" 2>/dev/null; then
        echo "$line" >> "$file"
        return 0
    fi
    return 1
}

# Backup a file
backup_file() {
    local file="$1"
    if [[ -f "$file" ]]; then
        cp "$file" "${file}.backup.$(date +%Y%m%d_%H%M%S)"
        print_info "Backed up $file"
    fi
}

# Wait for an app to be available
wait_for_app() {
    local app_name="$1"
    local max_wait="${2:-30}"
    local waited=0
    
    while ! app_installed "$app_name" && [[ $waited -lt $max_wait ]]; do
        sleep 1
        ((waited++))
    done
    
    app_installed "$app_name"
}

# Get the absolute path of a directory
get_script_dir() {
    cd "$(dirname "${BASH_SOURCE[0]}")" && pwd
}
