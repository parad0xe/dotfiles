export PYENV_ROOT="$HOME/.pyenv"
export EDITOR="/usr/bin/vim"

export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.local/share/junest/bin"
export PATH="$PATH:$HOME/.junest/usr/bin_wrappers"
export PATH="$PATH:$PYENV_ROOT/bin"

if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

if command -v zoxide >/dev/null 2>&1; then
    # Détection automatique du shell pour l'init
    shell_name=$(basename "$SHELL")
    eval "$(zoxide init $shell_name)"
fi

if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi
