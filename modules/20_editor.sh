#!/bin/bash

module_check() {
    local plug_path="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim"
    
    if ! file_exists "$plug_path"; then
        return $RET_MODULECHECK_REQUIRE_INSTALL
    fi

    case "$TARGET_SHELL" in
        fish)
            if ! fish_command_exists "tree-sitter"; then
                return $RET_MODULECHECK_REQUIRE_INSTALL
            fi
            ;;
        *)
            export NVM_DIR="$HOME/.nvm"
            non_empty_file "$NVM_DIR/nvm.sh" && \. "$NVM_DIR/nvm.sh" >/dev/null 2>&1
            if ! command_exists "tree-sitter"; then
                return $RET_MODULECHECK_REQUIRE_INSTALL
            fi
            ;;
    esac

    return $RET_MODULECHECK_DONOTHING
}

module_install() {
    header "Installing neovim & code tools"

    local plug_path="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim"
    
    info "Checking vim-plug..."
    if ! file_exists "$plug_path"; then
        _install_vim_plug "$plug_path"
    else
        success "Vim-plug already installed"
    fi

    blank
    info "Checking tree-sitter..."
    local ts_installed=false

    case "$TARGET_SHELL" in
        fish)
            fish_command_exists "tree-sitter" && ts_installed=true
            ;;
        *)
            export NVM_DIR="$HOME/.nvm"

			if ! dry_run; then
				if non_empty_file "$NVM_DIR/nvm.sh"; then
					\. "$NVM_DIR/nvm.sh" >/dev/null 2>&1
				fi
			fi
            command_exists "tree-sitter" && ts_installed=true
            ;;
    esac

    if ! $ts_installed; then
        _install_tree_sitter
    else
        success "Tree-sitter cli already installed"
    fi

    blank
    success "Editor neovim and code tools installed successfully"
}

module_configure() {
    header "Configuring neovim assets"

    info "Preparing neovim configuration directory..."
    safe_mkdir "$HOME/.config/nvim"

    blank
    info "Linking core configuration files..."
    step "Linking config.lua..."
    safe_link "$ASSETS_DIR/tools/nvim/config.lua" "$HOME/.config/nvim/config.lua"
    
    step "Linking init.vim..."
    safe_link "$ASSETS_DIR/tools/nvim/init.vim" "$HOME/.config/nvim/init.vim"

    blank
    info "Synchronizing lua modules..."
    safe_link_all "$ASSETS_DIR/tools/nvim/lua" "$HOME/.config/nvim/lua"

    blank
    success "Neovim environment synchronized"
}

# --- Internal helpers ---

_install_vim_plug() {
    local plug_path="$1"
    step "Downloading vim-plug..."
	ensure_has_command "curl"

	safe_execute curl -sfLo "$plug_path" --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	success "Vim-plug installed"
}

_install_tree_sitter() {
    step "Installing tree-sitter-cli via npm..."
	case "$TARGET_SHELL" in
		fish)	try_sudo fish -c "sudo npm install -g tree-sitter-cli" ;;
		*)
			ensure_has_command "npm"
			try_sudo npm install -g tree-sitter-cli
			;;
	esac
	success "Tree-sitter installed"
}
