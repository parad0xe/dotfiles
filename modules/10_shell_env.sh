#!/bin/bash

module_check() {
    case "$TARGET_SHELL" in
        fish)
            if ! fish_command_exists "fisher"; then
                return $RET_MODULECHECK_REQUIRE_INSTALL
            fi
            ;;
    esac
    
    if ! command_exists "zoxide"; then
        return $RET_MODULECHECK_REQUIRE_INSTALL
    fi

    return $RET_MODULECHECK_DONOTHING
}

module_install() {
    header "Installing shell environment tools"

    case "$TARGET_SHELL" in
        fish)
            if ! fish_command_exists "fisher"; then
                _install_fisher
            else
                success "Fisher already installed"
            fi
            blank
            ;;
    esac

    if ! command_exists "zoxide"; then
        _install_zoxide
    else
        success "Zoxide already installed"
    fi

    blank
    success "Shell environment tools installed successfully"
}

module_configure() {
    header "Configuring $TARGET_SHELL environment"

    info "Synchronizing assets for $TARGET_SHELL..."

    case "$TARGET_SHELL" in
        fish)
            safe_mkdir -p "$HOME/.config/fish"
            
            step "Linking config.fish..."
            safe_link "$ASSETS_DIR/shell/fish/config.fish" "$HOME/.config/fish/config.fish"
            
            step "Linking .bashrc..."
            safe_link "$ASSETS_DIR/shell/fish/.bashrc" "$HOME/.bashrc"
            
            blank
            info "Synchronizing fish functions..."
            safe_link_all "$ASSETS_DIR/shell/fish/functions" "$HOME/.config/fish/functions"
            ;;
        bash)
            step "Linking .bashrc..."
            safe_link "$ASSETS_DIR/shell/bash/.bashrc" "$HOME/.bashrc"
            ;;
        zsh)
            step "Linking .zshrc..."
            safe_link "$ASSETS_DIR/shell/zsh/.zshrc" "$HOME/.zshrc"
            ;;
    esac

    blank
    success "$TARGET_SHELL environment synchronized"
}

# --- Internal helpers ---

_install_fisher() {
    info "Installing fisher (fish plugin manager)..."

	ensure_has_command "fish"
	ensure_fish_has_command "curl"

	safe_execute fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
	success "Fisher installed successfully"
}

_install_zoxide() {
    info "Installing zoxide..."

	ensure_has_command "curl"

	safe_execute curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
	success "Zoxide installed successfully"
}
