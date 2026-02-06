#!/bin/bash

install_junest() {
	display_header "Install JuNest"
    export PATH="$JUNEST_ROOT/bin:$PATH"
	if [ ! -d "$JUNEST_ROOT" ]; then
        echo -e "\n== Installing JuNest (Arch Linux Jail) =="
        git clone --depth 1 https://github.com/fsquillace/junest.git "$JUNEST_ROOT"
		junest setup
    	junest -f -- sudo pacman --noconfirm -Syy
    	junest -f -- sudo pacman --noconfirm -Sy archlinux-keyring
    	echo -e "JuNest installed."
	else
    	echo -e "JuNest is already installed."
    fi
}

install_vim_plug() {
	display_header "Install VimPlug"
    local plug_path="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim"
    if [ ! -f "$plug_path" ]; then
        echo -e "\n== Installing Vim Plug =="
        curl -sfLo "$plug_path" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    	echo -e "VimPlug installed."
	else
    	echo -e "VimPlug is already installed."
    fi
}

install_nerd_font() {
	display_header "Install NerdFont"
    if [ ! -f "$FONT_DIR/JetBrainsMonoNLNerdFont-Thin.ttf" ]; then
        echo -e "\n== Installing Nerd Font =="
        mkdir -p "$TMP/nerd-font" "$FONT_DIR"
        wget -qP "$TMP/nerd-font" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
        unzip -q "$TMP/nerd-font/JetBrainsMono.zip" -d "$TMP/nerd-font"
        mv "$TMP/nerd-font/"*.ttf "$FONT_DIR/"
        fc-cache -f
    	echo -e "NerdFont installed."
	else
    	echo -e "NerdFont is already installed."
    fi
}

install_fisher() {
	display_header "Install Fisher"

	local fisher_func="$HOME/.config/fish/functions/fisher.fish"

	if [ ! -f "$fisher_func" ]; then
		fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
		echo "Fisher installed."
	else
		echo "Fisher is already installed."
	fi
}

install_pyenv() {
	display_header "Install Pyenv (Python version manager)"
	if [ ! -d "$HOME/.pyenv" ]; then
		curl -fsSL https://pyenv.run | bash
		echo "Pyenv installed."
	else
		echo "Pyenv is already installed."
	fi
}

install_nvm() {
	display_header "Install Nvm (Node version manager)"

	local nvm_func="$HOME/.config/fish/functions/nvm.fish"

	if [ ! -f "$nvm_func" ]; then
		fish -c "fisher install jorgebucaran/nvm.fish"
		fish -c "nvm install latest"
		echo "Nvm installed."
	else
		echo "Nvm is already installed."
	fi
}
configure_fish() {
	display_header "Configure Fish"
    mkdir -p "$HOME/.config/fish"
    ln -Tsf "$ASSETS/fish/config.fish" "$HOME/.config/fish/config.fish"
    link_assets "$ASSETS/fish/functions" "$HOME/.config/fish/functions"
    echo -e "Fish environment is now synchronized with assets."
}

configure_nvim() {
	display_header "Configure Neovim"
    mkdir -p "$HOME/.config/nvim/lua"
    ln -Tsf "$ASSETS/nvim/config.lua" "$HOME/.config/nvim/config.lua"
    ln -Tsf "$ASSETS/nvim/init.vim" "$HOME/.config/nvim/init.vim"
    ln -Tsfn "$ASSETS/nvim/lua/config" "$HOME/.config/nvim/lua/config"
    echo -e "Neovim environment is now synchronized with assets." 
}

# --- Entry Point ---

install() {
	mkdir -p "$TMP"

	if ! has_sudo; then
		if [ ! -d "$JUNEST_ROOT" ]; then
			echo -e "\n[!] Sudo access not detected. To proceed without root, JuNest (Arch Linux Jail) is required."

			local msg="Install JuNest in $JUNEST_ROOT and continue?"
			if [ "${FORCE:-false}" = true ] || confirm "$msg"; then
				echo "--> Initializing JuNest installation..."
				install_junest
			else
				echo -e "\n[ERROR] Unprivileged environment setup declined."
				echo "This script requires either sudo or JuNest to manage system dependencies."
				exit "$ERR_SUDO"
			fi
		else
			echo "JuNest is installed."
		fi
	fi

    # 1. System dependencies
    pkg_install fish curl wget unzip git man make

	if [ ! -f "$(which fish)" ]; then
    	pkg_install fish
	fi

    # 2. Specific tools
    pkg_install lazygit which vim neovim pygmentize tree-sitter-cli

    # 3. Module execution
    install_vim_plug
    install_nerd_font
	install_fisher
	install_pyenv
	install_nvm
   
	display_header "Linking assets"
    link_assets "$ASSETS/bin" "$BIN_DIR"
    link_assets "$ASSETS/scripts" "$BIN_DIR"
    
	configure_fish
    configure_nvim

    # Cleanup
    rm -rf "$TMP"
	echo -e "\n[SUCCESS] Installation complete."
    echo -e "[Done] Restart your shell and run :PlugInstall inside nvim"
}

