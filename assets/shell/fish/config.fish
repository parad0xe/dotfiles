if status is-interactive
    # Commands to run in interactive sessions can go here
end

function fish_prompt
    # Sauvegarder le code retour de la dernière commande
	set -l last_status $status

	set -l junest_str ""
    if set -q JUNEST_ENV
        set junest_str (set_color blue)"[JuNest] "(set_color normal)
    end

	# Couleur selon succès/échec
	set -l color_status (test $last_status -eq 0; and echo green; or echo red)
	set -l status_str (set_color $color_status)"[$last_status]"(set_color normal)

	# Nom d'utilisateur (cyan)
	set -l user_str (set_color cyan)(whoami)(set_color normal)

	# PWD (violet)
	set -l pwd_str (set_color magenta)(prompt_pwd)(set_color normal)

	# Git (jaune)
	set -l git_str (set_color yellow)(fish_git_prompt)(set_color normal)

	# Prompt final
	echo ""
	echo "$status_str $junest_str$user_str $pwd_str$git_str"
	echo -n (set_color $color_status)"> "(set_color normal)
end

set -g fish_prompt_pwd_dir_length 4

fish_add_path -gPa $HOME/.cargo/bin
fish_add_path -gPa $HOME/.local/bin
fish_add_path -gPa $HOME/.local/share/junest/bin
fish_add_path -gPa $HOME/.junest/usr/bin_wrappers

export PYENV_ROOT="$HOME/.pyenv"
fish_add_path -gPa $PYENV_ROOT/bin
if type -q pyenv
	pyenv init - | source
end

if type -q nvm
	nvm --silent use latest
end

export EDITOR=/usr/bin/vim

alias c="cc -Wall -Wextra -Werror"
alias n="norminette"
alias ll="ls -la"

if type -q nvim
	alias vim="nvim"
end

if type -q python3
	alias py="python3"
end

if type -q pygmentize
	alias cat="pygmentize -g"
end

if type -q junest
	alias j="junest -- fish"
end

# create and move into tempd directory
alias cdmk="cd (mktemp -d)"

# git log (oneline)
alias gl="git log --oneline"

# git short log by users
alias gsl="git shortlog"

if test -f "$HOME/.cargo/env.fish"
	source "$HOME/.cargo/env.fish"
end

if type -q zoxide
    zoxide init fish | source
end
