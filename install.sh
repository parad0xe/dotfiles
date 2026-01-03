#!/bin/bash

ASSETS=$PWD/assets
TMP=$PWD/tmp

function download_vim_plug
{
	echo ""
	echo "== Vim Plug =="
	if [ ! -f "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/site/autoload/plug.vim" ]; then
		sh -c 'curl -sfLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim \
			--create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim' \
			1>/dev/null
		status=$?
		if [ $status -ne 0 ]; then
			echo "failed";
			exit 1
		fi
	fi
	echo "done"
}

function download_nerd_font
{
	echo ""
	echo "== Nerd Font =="
	if [ ! -f "$HOME/.local/share/fonts/JetBrainsMonoNLNerdFont-Thin.ttf" ]; then
		mkdir -p $TMP/nerd-font
		mkdir -p $HOME/.local/share/fonts
		wget -qP $TMP/nerd-font https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/JetBrainsMono.zip
		cd $TMP/nerd-font
		unzip JetBrainsMono.zip 1>/dev/null
		mv *.ttf $HOME/.local/share/fonts
		cd ../..
		fc-cache -fv 1>/dev/null
	fi
	echo "done"
}

function configure_nvim
{
	echo ""
	echo "== Configure Nvim =="
	mkdir -p $HOME/.config/nvim
	ln -sf $ASSETS/nvim/config.lua $HOME/.config/nvim/config.lua
	ln -sf $ASSETS/nvim/init.vim $HOME/.config/nvim/init.vim 
	echo "done"
}

function install_bin
{
	echo ""
	echo "== Install binaries =="
	mkdir -p $HOME/.local/bin
	for bin in $(ls $ASSETS/bin); do
		echo -n "install $bin into $HOME/.local/bin.. "
		cp $ASSETS/bin/$bin $HOME/.local/bin
		echo "OK"
	done
	echo "done"
}

download_vim_plug
download_nerd_font
configure_nvim
install_bin

rm -rf $TMP

echo ""
echo "[info] open nvim and run :PlugInstall"
