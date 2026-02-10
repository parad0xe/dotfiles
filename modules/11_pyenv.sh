#!/bin/bash

module_check() {
    if ! dir_exists "$HOME/.pyenv"; then
        return $RET_MODULECHECK_REQUIRE_INSTALL
    fi

    return $RET_MODULECHECK_DONOTHING
}

module_install() {
    header "Installing pyenv"

    _install_pyenv

    blank
    success "Pyenv installation process completed"
}

module_configure() {
    header "Checking pyenv shell integration"
    
    info "Manual configuration required:"
    muted "Ensure your shell configuration (assets) includes pyenv init commands"

    blank
    tips 'export PYENV_ROOT="$HOME/.pyenv"'
    tips '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"'
    tips 'eval "$(pyenv init -)"'
}

# --- Internal helpers ---

_install_pyenv() {
    info "Installing pyenv (python version manager)..."
    
	ensure_has_command "curl"

	safe_execute curl -fsSL https://pyenv.run | bash
	success "Pyenv binaries installed successfully"
}
