#!/bin/bash

confirm() {
    local prompt="${1:-Are you sure ?} [y/N] "
    read -r -p "$prompt" response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            return $OK
            ;;
        *)
            return $ERR
            ;;
    esac
}

display_header() {
    local title="      $1      "
    local edge=$(echo "$title" | sed 's/./=/g')
    echo -e "\n+${edge}+"
    echo -e "|${title}|"
    echo -e "+${edge}+\n"
}

has_sudo() {
    local sudo_path
    
    sudo_path=$(command -v sudo 2>/dev/null) || return 1

    if [[ "$sudo_path" == *".junest"* ]]; then
        return $ERR_SUDO
    fi

    if [ -n "${JUNEST_ENV:-}" ]; then
        return $ERR_SUDO
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
				exit $ERR
				;;
		esac
	else
        # Fallback to JuNest (always uses pacman)
        junest -f -- sudo pacman -Syu --noconfirm --needed "$@"
    fi
}

pkg_uninstall() {
    echo -e "\n== Uninstalling packages: $* =="
	if has_sudo; then
		case "$ID" in
			arch)
				sudo pacman -Rcns --noconfirm "$@"
				;;
			debian|ubuntu)
				sudo apt-get autoremove -y "$@"
				;;
			*)
				echo "Unsupported distribution: $ID"
				exit $ERR
				;;
		esac
	else
        # Fallback to JuNest (always uses pacman)
        junest -f -- sudo pacman -Rcns --noconfirm "$@"
    fi
}

# Generic symbolic link function
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
