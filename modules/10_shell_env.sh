#!/bin/bash

module_check() {
    case "$TARGET_SHELL" in
        fish)
            if ! fish_command_exists "fisher"; then
                return $RET_MODULE_DOEXECUTE
            fi

			if ! safe_execute fish -c "fisher list | grep -q fzf.fish" 2>/dev/null; then
                return $RET_MODULE_DOEXECUTE
            fi
            ;;
		zsh)
            if ! dir_exists "$HOME/.oh-my-zsh"; then
                return $RET_MODULE_DOEXECUTE
            fi
            ;;
    esac
    
    if ! command_exists "zoxide"; then
        return $RET_MODULE_DOEXECUTE
    fi

    return $RET_MODULE_DONOTHING
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
		zsh)
            if ! dir_exists "$HOME/.oh-my-zsh"; then
                _install_oh_my_zsh
            else
                success "Oh-My-Zsh already installed"
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
            safe_mkdir "$HOME/.config/fish"
            safe_link "$ASSETS_DIR/shell/fish/config.fish" "$HOME/.config/fish/config.fish"
            safe_link_all "$ASSETS_DIR/shell/fish/functions" "$HOME/.config/fish/functions"

			info "Configuring fzf for fish..."
            safe_execute fish -c "fisher install PatrickF1/fzf.fish"
            ;;
        bash)
            safe_link "$ASSETS_DIR/shell/bash/.bashrc" "$HOME/.bashrc"
            ;;
        zsh)
            safe_link "$ASSETS_DIR/shell/zsh/.zshrc" "$HOME/.zshrc"
            ;;
    esac

    blank
    success "$TARGET_SHELL environment synchronized"
}

module_uninstall() {
    header "Uninstalling shell environment configurations and tools"
    
    if force_confirm || confirm "Do you want to remove $TARGET_SHELL configurations and associated tools (zoxide, fisher)?"; then
        info "Removing shell environment tools..."
        
        safe_rm "$LOCAL_BIN_DIR/zoxide"

        if target_shell_is "fish" && fish_command_exists "fisher"; then
			blank
            info "Uninstalling fisher and its plugins..."
            safe_execute fish -c "fisher remove PatrickF1/fzf.fish"
            safe_execute fish -c "fisher remove jorgebucaran/fisher"
        fi

		if target_shell_is "zsh" && dir_exists "$HOME/.oh-my-zsh"; then
            blank
            info "Uninstalling Oh-My-Zsh..."
            safe_rm "$HOME/.oh-my-zsh"
        fi

		blank
        info "Removing shell configuration links..."

        case "$TARGET_SHELL" in
            fish) 
                safe_rm \
                    "$HOME/.config/fish/functions"
                ;;
        esac

        blank
        success "$TARGET_SHELL environment and tools removed (consider restoring your backups)"
    else
        muted "Shell configuration uninstallation skipped."
    fi
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

_install_oh_my_zsh() {
    info "Installing Oh-My-Zsh..."

    ensure_has_command "curl"
    ensure_has_command "git"

    safe_execute sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    success "Oh-My-Zsh installed successfully"
}
