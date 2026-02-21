# ============================================================
# Oh-My-Zsh Configuration
# ============================================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(git colored-man-pages colorize python zoxide)

source $ZSH/oh-my-zsh.sh

if [[ -n "${JUNEST_ENV:-}" ]]; then
    PROMPT="%{$fg_bold[blue]%}[JuNest] %{$reset_color%}${PROMPT}"
fi

# ============================================================
# Environment Variables
# ============================================================
export PYENV_ROOT="$HOME/.pyenv"
export EDITOR="/usr/bin/vim"

export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.local/share/junest/bin"
export PATH="$PATH:$HOME/.junest/usr/bin_wrappers"
export PATH="$PATH:$PYENV_ROOT/bin"

# ============================================================
# Aliases & Functions
# ============================================================
alias ls="ls --color=auto"
alias ll="ls -la --color=auto"
alias grep="grep --color=auto"

alias c="cc -Wall -Wextra -Werror"
alias cdmk='cd $(mktemp -d)'

alias glg="git log --oneline"
alias gsl="git shortlog"

if command -v nvim >/dev/null 2>&1; then alias vim="nvim"; fi
if command -v python3 >/dev/null 2>&1; then alias py="python3"; fi
if command -v pygmentize >/dev/null 2>&1; then alias cat="pygmentize -g"; fi
if command -v junest >/dev/null 2>&1; then alias j="junest -- zsh"; fi

# ============================================================
# Init tools
# ============================================================
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init zsh)"
fi

if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi
