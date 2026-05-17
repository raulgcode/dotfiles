#!/bin/bash

#===============================================================================
# GitHub Multi-Account Configuration (SSH + per-directory Git identity)
#===============================================================================

GITHUB_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$GITHUB_SCRIPT_DIR/utils.sh" ]; then
    # shellcheck source=/dev/null
    source "$GITHUB_SCRIPT_DIR/utils.sh"
fi

# Fallback output helpers if not loaded from utils.sh
if ! declare -f print_step >/dev/null 2>&1; then
    print_step() { echo "[STEP] $1"; }
fi
if ! declare -f print_success >/dev/null 2>&1; then
    print_success() { echo "[OK]   $1"; }
fi
if ! declare -f print_warning >/dev/null 2>&1; then
    print_warning() { echo "[WARN] $1"; }
fi
if ! declare -f print_error >/dev/null 2>&1; then
    print_error() { echo "[ERR]  $1"; }
fi
if ! declare -f print_info >/dev/null 2>&1; then
    print_info() { echo "[INFO] $1"; }
fi
if ! declare -f command_exists >/dev/null 2>&1; then
    command_exists() { command -v "$1" >/dev/null 2>&1; }
fi

prompt_if_empty() {
    local var_name="$1"
    local prompt_text="$2"
    local default_value="${3:-}"
    local current_value="${!var_name:-}"

    if [[ -n "$current_value" ]]; then
        return 0
    fi

    if [[ -n "$default_value" ]]; then
        read -r -p "$prompt_text [$default_value]: " current_value
        current_value="${current_value:-$default_value}"
    else
        read -r -p "$prompt_text: " current_value
    fi

    printf -v "$var_name" '%s' "$current_value"
}

open_url() {
    local url="$1"
    if command_exists open; then
        open "$url" >/dev/null 2>&1
        return $?
    fi
    return 1
}

copy_key_to_clipboard() {
    local pub_key_path="$1"
    if command_exists pbcopy && [[ -f "$pub_key_path" ]]; then
        pbcopy < "$pub_key_path"
        return 0
    fi
    return 1
}

open_github_ssh_registration_flow() {
    local personal_pub="$1"
    local work_pub="$2"
    local keys_url="https://github.com/settings/ssh/new"

    if [[ "${OPEN_GITHUB_SSH_PAGES:-1}" != "1" ]]; then
        print_info "Skipping browser launch (set OPEN_GITHUB_SSH_PAGES=1 to enable)"
        return 0
    fi

    if ! command_exists open; then
        print_warning "Cannot open browser automatically on this platform"
        print_info "Open this URL manually: $keys_url"
        return 0
    fi

    echo ""
    print_step "Register PERSONAL SSH key on GitHub"
    if copy_key_to_clipboard "$personal_pub"; then
        print_info "Personal public key copied to clipboard"
    else
        print_info "Copy this key manually from: $personal_pub"
    fi
    open_url "$keys_url" || true
    print_info "Sign in to your PERSONAL GitHub account and add the key"
    if [ -t 0 ]; then
        read -r -p "Press Enter after the PERSONAL key is added..."
    fi

    echo ""
    print_step "Register WORK SSH key on GitHub"
    if copy_key_to_clipboard "$work_pub"; then
        print_info "Work public key copied to clipboard"
    else
        print_info "Copy this key manually from: $work_pub"
    fi
    open_url "$keys_url" || true
    print_info "Sign in to your WORK GitHub account and add the key"
    if [ -t 0 ]; then
        read -r -p "Press Enter after the WORK key is added..."
    fi
}

ensure_ssh_key() {
    local key_path="$1"
    local key_comment="$2"
    local pub_key_path="${key_path}.pub"

    if [[ -f "$key_path" ]]; then
        print_success "SSH key already exists: $key_path"
    else
        print_step "Generating SSH key: $key_path"
        mkdir -p "$(dirname "$key_path")"

        if ssh-keygen -t ed25519 -C "$key_comment" -f "$key_path" -N "" >/dev/null 2>&1; then
            print_success "Created SSH key: $key_path"
        else
            print_error "Failed to create SSH key: $key_path"
            return 1
        fi
    fi

    # Ensure public key exists and is in OpenSSH public format
    if [[ ! -f "$pub_key_path" ]] || ! grep -q '^ssh-ed25519 ' "$pub_key_path" 2>/dev/null; then
        print_step "Generating public key from private key: $pub_key_path"
        if ssh-keygen -y -f "$key_path" > "$pub_key_path" 2>/dev/null; then
            chmod 644 "$pub_key_path" 2>/dev/null || true
            print_success "Public key ready: $pub_key_path"
        else
            print_error "Failed to generate public key: $pub_key_path"
            return 1
        fi
    else
        print_success "Public key already valid: $pub_key_path"
    fi

    return 0
}

ensure_ssh_host_entry() {
    local host_alias="$1"
    local identity_file="$2"
    local ssh_config="$HOME/.ssh/config"

    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    touch "$ssh_config"

    if grep -q "^Host $host_alias$" "$ssh_config"; then
        print_info "SSH host alias already exists: $host_alias"
        return 0
    fi

    cat >> "$ssh_config" <<EOF

Host $host_alias
  HostName github.com
  User git
  IdentityFile $identity_file
  IdentitiesOnly yes
EOF

    chmod 600 "$ssh_config"
    print_success "Added SSH host alias: $host_alias"
}

write_git_profile() {
    local profile_path="$1"
    local user_name="$2"
    local user_email="$3"

    if [[ -z "$user_name" || -z "$user_email" ]]; then
        print_warning "Skipping profile $profile_path because name/email is empty"
        return 0
    fi

    cat > "$profile_path" <<EOF
[user]
    name = $user_name
    email = $user_email
EOF

    print_success "Wrote Git profile: $profile_path"
}

ensure_git_includeif() {
    local git_dir_pattern="$1"
    local include_path="$2"
    local key="includeIf.gitdir:${git_dir_pattern}.path"

    local existing
    existing=$(git config --global --get "$key" 2>/dev/null || true)

    if [[ "$existing" == "$include_path" ]]; then
        print_info "Git includeIf already configured for $git_dir_pattern"
        return 0
    fi

    git config --global "$key" "$include_path"
    print_success "Configured includeIf for $git_dir_pattern"
}

print_next_steps() {
    local personal_pub="$1"
    local work_pub="$2"
    local personal_alias="$3"
    local work_alias="$4"

    echo ""
    print_info "Next steps:"
    echo "  1. Add these public keys to the matching GitHub accounts:"
    echo "     - $personal_pub"
    echo "     - $work_pub"
    echo "  2. Test both SSH identities:"
    echo "     - ssh -T git@$personal_alias"
    echo "     - ssh -T git@$work_alias"
    echo "  3. Clone repos with aliases:"
    echo "     - git clone git@$personal_alias:USERNAME/REPO.git"
    echo "     - git clone git@$work_alias:ORG/REPO.git"
}

main() {
    if ! command_exists ssh-keygen; then
        print_error "ssh-keygen is required but not found"
        return 1
    fi

    if ! command_exists git; then
        print_error "git is required but not found"
        return 1
    fi

    print_step "Configuring two GitHub accounts (SSH + Git identities)"

    prompt_if_empty PERSONAL_ACCOUNT_NAME "Personal Git user name"
    prompt_if_empty PERSONAL_ACCOUNT_EMAIL "Personal Git email"
    prompt_if_empty WORK_ACCOUNT_NAME "Work Git user name"
    prompt_if_empty WORK_ACCOUNT_EMAIL "Work Git email"

    prompt_if_empty PERSONAL_HOST_ALIAS "SSH host alias for personal GitHub" "github-personal"
    prompt_if_empty WORK_HOST_ALIAS "SSH host alias for work GitHub" "github-work"

    prompt_if_empty PERSONAL_KEY_PATH "Personal SSH private key path" "$HOME/.ssh/id_ed25519_github_personal"
    prompt_if_empty WORK_KEY_PATH "Work SSH private key path" "$HOME/.ssh/id_ed25519_github_work"

    prompt_if_empty PERSONAL_GITDIR "Personal repos directory pattern" "$HOME/code/personal/"
    prompt_if_empty WORK_GITDIR "Work repos directory pattern" "$HOME/code/work/"

    ensure_ssh_key "$PERSONAL_KEY_PATH" "$PERSONAL_ACCOUNT_EMAIL" || return 1
    ensure_ssh_key "$WORK_KEY_PATH" "$WORK_ACCOUNT_EMAIL" || return 1

    ensure_ssh_host_entry "$PERSONAL_HOST_ALIAS" "$PERSONAL_KEY_PATH"
    ensure_ssh_host_entry "$WORK_HOST_ALIAS" "$WORK_KEY_PATH"

    write_git_profile "$HOME/.gitconfig-personal" "$PERSONAL_ACCOUNT_NAME" "$PERSONAL_ACCOUNT_EMAIL"
    write_git_profile "$HOME/.gitconfig-work" "$WORK_ACCOUNT_NAME" "$WORK_ACCOUNT_EMAIL"

    ensure_git_includeif "$PERSONAL_GITDIR" "$HOME/.gitconfig-personal"
    ensure_git_includeif "$WORK_GITDIR" "$HOME/.gitconfig-work"

    if command_exists ssh-add; then
        ssh-add --apple-use-keychain "$PERSONAL_KEY_PATH" >/dev/null 2>&1 || true
        ssh-add --apple-use-keychain "$WORK_KEY_PATH" >/dev/null 2>&1 || true
    fi

    open_github_ssh_registration_flow "$PERSONAL_KEY_PATH.pub" "$WORK_KEY_PATH.pub"

    print_success "GitHub multi-account configuration completed"
    print_next_steps "$PERSONAL_KEY_PATH.pub" "$WORK_KEY_PATH.pub" "$PERSONAL_HOST_ALIAS" "$WORK_HOST_ALIAS"
}

main "$@"
