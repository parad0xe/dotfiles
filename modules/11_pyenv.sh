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
 
	info "Checking pyenv shell integration in $TARGET_SHELL_RC..."

	if ! grep -q "PYENV_ROOT" "$TARGET_SHELL_RC" 2>/dev/null; then
		if force_confirm || confirm "Add pyenv configuration to your $TARGET_SHELL_RC ?"; then
			info "Updating $TARGET_SHELL_RC..."

			{
				echo -e "\n# pyenv settings"
				if [[ "$TARGET_SHELL" == "fish" ]]; then
					echo 'set -gx PYENV_ROOT "$HOME/.pyenv"'
					echo 'fish_add_path "$PYENV_ROOT/bin"'
					echo 'pyenv init - | source'
				else
					echo 'export PYENV_ROOT="$HOME/.pyenv"'
					echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PATH:$PYENV_ROOT/bin"'
					echo 'eval "$(pyenv init -)"'
				fi
			} >> "${TMP_DIR}/.pyenv_rc"

			backup_file "$TARGET_SHELL_RC"
			safe_execute mv "${TMP_DIR}/.pyenv_rc" "$TARGET_SHELL_RC"

			success "Configuration injected into $TARGET_SHELL_RC"
		else
			warn "Automatic configuration skipped."
			info "To complete the setup, manually add these lines to $TARGET_SHELL_RC:"

			blank
			if [[ "$TARGET_SHELL" == "fish" ]]; then
				tips 'set -gx PYENV_ROOT "$HOME/.pyenv"'
				tips 'fish_add_path "$PYENV_ROOT/bin"'
				tips 'pyenv init - | source'
			else
				tips 'export PYENV_ROOT="$HOME/.pyenv"'
				tips '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PATH:$PYENV_ROOT/bin"'
				tips 'eval "$(pyenv init -)"'
			fi
			blank
		fi
	fi

	blank
    success "$TARGET_SHELL pyenv environment is ready"
}

# --- Internal helpers ---

_install_pyenv() {
    info "Installing pyenv (python version manager)..."
    
	ensure_has_command "curl"

	if [[ "$RUN_COMMAND" == "reinstall" ]]; then
		safe_execute rm -rf "$HOME/.pyenv"
	fi

	safe_execute curl -fsSL https://pyenv.run | bash
	success "Pyenv binaries installed successfully"
}
