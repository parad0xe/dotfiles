#!/bin/bash

module_init() {
    export PATH="$JUNEST_EXEC_DIR:$PATH:$JUNEST_BIN_WRAPPERS_DIR"

	if ! has_sudo || dir_exists "$JUNEST_ROOT_DIR"; then
    	ID="arch"
	fi
}

module_check() {
	if ! has_sudo; then
		if ! dir_exists "$JUNEST_ROOT_DIR" || ! command_exists junest; then
			return $RET_MODULECHECK_REQUIRE_INSTALL
		fi
	fi

	return $RET_MODULECHECK_DONOTHING
}

module_install() {
	header "Installing junest (unprivileged jail)"
	
    warn "Sudo access not detected. To proceed without root, junest is required"
	
	if force_confirm || confirm "Install junest in $JUNEST_DIR and continue ?"; then
		_install_junest
	else
		err "Unprivileged environment setup declined"
		fatal "This script requires either sudo or junest to manage system dependencies"
	fi

	blank
	success "Junest installed successfully"			
}

module_configure() {
	header "Configuring junest environment"
    
    info "Updating junest package databases..."
    _configure_junest
    
    blank
    success "Junest environment is ready"
}

# --- Internal helpers ---

_install_junest() {
    info "Cloning junest repository..."

    ensure_has_command "git"
    safe_execute git clone --depth 1 https://github.com/fsquillace/junest.git "$JUNEST_DIR"

    step "Running junest setup..."
    safe_execute junest setup
}

_configure_junest() {
    safe_execute junest -- sudo pacman --noconfirm -Syy
    safe_execute junest -- sudo pacman --noconfirm -Sy archlinux-keyring
}
