#!/bin/bash

command_exists() {
	if dry_run; then
		return $RETOK
	fi
	command -v "$1" >/dev/null 2>&1 || which "$1" 2>/dev/null
}

fish_command_exists() {
	if dry_run; then
		return $RETOK
	fi
	ensure_has_command "fish"
	fish -c "functions -q $1" >/dev/null 2>&1
}

ensure_has_command() {
	if dry_run; then
		return $RETOK
	fi
	if ! command_exists "$1"; then
		fatal "Command $1 not found"
	fi
}

ensure_fish_has_command() {
	if dry_run; then
		return $RETOK
	fi
	if ! fish_command_exists "$1"; then
		fatal "Fish command $1 not found"
	fi
}

safe_execute() {
    if dry_run; then
        dry "$*"
    else
        "$@"
    fi
}

require_junest() {
    if ! command_exists sudo; then
        warn "Sudo access not detected. To proceed without root, junest is required"
    fi

    export PATH="$JUNEST_EXEC_DIR:$PATH:$JUNEST_BIN_WRAPPERS_DIR"
    if ! dir_exists "$JUNEST_ROOT_DIR" || ! command_exists junest; then
        if force_confirm || confirm "Install junest in $JUNEST_DIR and continue?"; then
            header "Installing junest (arch linux jail)"
            
            safe_execute git clone --depth 1 https://github.com/fsquillace/junest.git "$JUNEST_DIR"
            safe_execute junest setup
            safe_execute sudo pacman --noconfirm -Syy
            safe_execute sudo pacman --noconfirm -Sy archlinux-keyring
            
            success "Junest installed"
        else
            err "Unprivileged environment setup declined"
            fatal "This script requires either sudo or junest to manage system dependencies"
        fi
    else
        safe_execute sudo pacman --noconfirm -Syy
        safe_execute sudo pacman --noconfirm -Sy archlinux-keyring
    fi
}

has_sudo() {
	local test_sudo_msg=$(LC_ALL=C sudo -ln 2>&1)
	local test_sudo_ret=$?

	[ $test_sudo_ret -eq 0 ] || "$test_sudo_msg" | grep -q "password is required"
}

try_sudo() {
	info "Executing on $ID 'sudo $*'"

    if ! has_sudo; then
        require_junest
    fi

    if command_exists sudo; then
        if ! safe_execute sudo "$@"; then
            fatal "Failed to run 'sudo $*'"
        fi
    else
        fatal "Failed to run 'sudo $*'"
    fi
}

distro_install() {
    local cmd=""
    case "$ID" in
        arch)
            cmd="pacman -Syu --noconfirm --needed"
            ;;
        debian|ubuntu)
            cmd="apt install -y"
            ;;
        *) 
            fatal "Unsupported distribution: $ID"
            ;;
    esac

    try_sudo $cmd "$@"
}

pkg_install() {
    local target_os="all" 
    case "$1" in
        --both) shift ;;
        --arch-only) target_os="arch"; shift ;;
        --debian-only|--ubuntu-only) target_os="debian_ubuntu"; shift ;;
        *) fatal "Unknown flag in pkg_install: $1" ;;
    esac

    if [[ $# -eq 0 ]]; then
        warn "No packages provided to pkg_install, skipping"
        return 0
    fi

    case "$target_os" in
        arch)          [[ "$ID" == "arch" ]] && distro_install "$@" || true ;;
        debian_ubuntu) [[ "$ID" =~ debian|ubuntu ]] && distro_install "$@" || true ;;
        all)           distro_install "$@" ;;
        *)             fatal "Unsupported target os $target_os" ;;
    esac
}

detect_os() {
	if [ -f /etc/os-release ]; then
		. /etc/os-release
	else
		fatal "Unable to detect distribution."
	fi
}

