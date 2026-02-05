#!/bin/bash

# Exit immediately on error, undefined variable, or pipe failure
set -euo pipefail

# Environment Variables
ASSETS="${PWD}/assets"
TMP="${PWD}/tmp"
BIN_DIR="${HOME}/.local/bin"
FONT_DIR="${HOME}/.local/share/fonts"
JUNEST_ROOT="${HOME}/.local/share/junest"

# --- Utilities ---

# Distribution detection
if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Error: Unable to detect distribution."
    exit 1
fi

# Check if the user can use sudo non-interactively
has_sudo() {
    local sudo_path
    
    sudo_path=$(command -v sudo 2>/dev/null) || return 1

    if [[ "$sudo_path" == *".junest"* ]]; then
        return 1
    fi

    if [ -n "${JUNEST_ENV:-}" ]; then
        return 1
    fi

    sudo -n true 2>/dev/null || [ -w /etc/shadow ]
}

# Package manager abstraction
pkg_install() {
    echo -e "\n== Installing packages: $* =="
	if has_sudo; then
		case "$ID" in
			arch)
				sudo pacman -Syu --noconfirm --needed "$@"
				;;
			debian|ubuntu)
				sudo apt-get update -qq
				sudo apt-get install -y -qq "$@"
				;;
			*)
				echo "Unsupported distribution: $ID"
				exit 1
				;;
		esac
	else
        # Fallback to JuNest (always uses pacman)
        junest -f -- sudo pacman -Syu --noconfirm --needed "$@"
    fi
}

# Generic symbolic link function (DRY Principle)
link_assets() {
    local src="$1"
    local dst="$2"
	local b_src="$(basename $src)"
    echo -e "\n== Linking $b_src to $dst =="
    mkdir -p "$dst"
    for item in "$src"/*; do
        [ -e "$item" ] || continue
		echo "link '$(basename $item)' -> '$dst/'"
		ln -sf "$item" "$dst/$(basename $item)"
    done
}

# --- Installation Functions ---

install_junest() {
    export PATH="$JUNEST_ROOT/bin:$PATH"
	if [ ! -d "$JUNEST_ROOT" ]; then
        echo -e "\n== Sudo unavailable: Installing JuNest (Arch Linux Jail) =="
        git clone --depth 1 https://github.com/fsquillace/junest.git "$JUNEST_ROOT"
		junest setup
		junest -f -- pacman-key --init
        junest -f -- pacman-key --populate archlinux
    fi
}

install_vim_plug() {
    local plug_path="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim"
    if [ ! -f "$plug_path" ]; then
        echo -e "\n== Installing Vim Plug =="
        curl -sfLo "$plug_path" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    fi
}

install_nerd_font() {
    if [ ! -f "$FONT_DIR/JetBrainsMonoNLNerdFont-Thin.ttf" ]; then
        echo -e "\n== Installing Nerd Font =="
        mkdir -p "$TMP/nerd-font" "$FONT_DIR"
        wget -qP "$TMP/nerd-font" https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
        unzip -q "$TMP/nerd-font/JetBrainsMono.zip" -d "$TMP/nerd-font"
        mv "$TMP/nerd-font/"*.ttf "$FONT_DIR/"
        fc-cache -f
    fi
}

configure_fish() {
    echo -e "\n== Configuring Fish =="
    mkdir -p "$HOME/.config/fish"
    ln -Tsf "$ASSETS/fish/config.fish" "$HOME/.config/fish/config.fish"
    link_assets "$ASSETS/fish/functions" "$HOME/.config/fish/functions"
}

configure_nvim() {
    echo -e "\n== Configuring Neovim =="
    mkdir -p "$HOME/.config/nvim/lua"
    ln -Tsf "$ASSETS/nvim/config.lua" "$HOME/.config/nvim/config.lua"
    ln -Tsf "$ASSETS/nvim/init.vim" "$HOME/.config/nvim/init.vim"
    ln -Tsfn "$ASSETS/nvim/lua/config" "$HOME/.config/nvim/lua/config"
}

# --- Entry Point ---

main() {
	if ! has_sudo; then
    	install_junest
	fi

    # 1. System dependencies
    pkg_install curl wget unzip git man

    # 2. Specific tools
    pkg_install fish vim neovim pygmentize

    # 3. Module execution
    install_vim_plug
    install_nerd_font
    
    link_assets "$ASSETS/bin" "$BIN_DIR"
    link_assets "$ASSETS/scripts" "$BIN_DIR"
    
	configure_fish
    configure_nvim

    # Cleanup
    rm -rf "$TMP"
    echo -e "\n[Done] Restart your shell and run :PlugInstall inside nvim"
}

main "$@"
