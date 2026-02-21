# ============================================================
# Shell options & Prompt
# ============================================================
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

__update_bash_prompt() {
    local junest_str=""
    local git_str=""

    if [[ -n "${JUNEST_ENV:-}" ]]; then
        junest_str="\[\033[01;34m\][JuNest] \[\033[00m\]"
    fi

    local branch
    branch=$(git branch --show-current 2>/dev/null)
    if [[ -n "$branch" ]]; then
        git_str=" \[\033[33m\]git:($branch)\[\033[00m\]"
    fi

    PS1="${junest_str}\[\033[01;32m\]\u\[\033[00m\]:\[\033[01;35m\]\w\[\033[00m\]${git_str}\$ "
}

export PROMPT_COMMAND=__update_bash_prompt

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
alias n="norminette"

alias cdmk='cd $(mktemp -d)'

alias gl="git log --oneline"
alias gsl="git shortlog"

if command -v nvim >/dev/null 2>&1; then alias vim="nvim"; fi
if command -v python3 >/dev/null 2>&1; then alias py="python3"; fi
if command -v pygmentize >/dev/null 2>&1; then alias cat="pygmentize -g"; fi
if command -v junest >/dev/null 2>&1; then alias j="junest -- bash"; fi

# ============================================================
# Init tools
# ============================================================
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

if command -v zoxide >/dev/null 2>&1; then
    eval "$(zoxide init bash)"
fi

if [ -f "$HOME/.cargo/env" ]; then
    . "$HOME/.cargo/env"
fi

















export PYENV_ROOT="$HOME/.pyenv"
export EDITOR="/usr/bin/vim"

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
