#!/bin/bash

module_check() {
    if ! command_exists "lazygit"; then
        return $RET_MODULECHECK_REQUIRE_INSTALL
    fi

    return $RET_MODULECHECK_DONOTHING
}

module_install() {
    header "Installing lazygit"

    _install_lazygit

    blank
    success "Lazygit installation process completed"
}

module_configure() {
    return $RETOK
}

# --- Internal helpers ---

_install_lazygit() {
    info "Installing lazygit binary..."

	ensure_has_command "curl"
	ensure_has_command "tar"
	ensure_has_command "grep"

	local version
	version=$(get_github_latest_release "jesseduffield/lazygit")
	
	step "Detected version: $version"

	local archive_name="lazygit.tar.gz"
	local bin="lazygit"

	blank
	info "Downloading lazygit archive..."
	safe_execute curl -fsSL --output-dir "$TMP_DIR" -o "$archive_name" \
		"https://github.com/jesseduffield/lazygit/releases/download/${version}/lazygit_${version#v}_Linux_x86_64.tar.gz"
	
	blank
	info "Extracting and moving binary..."
	safe_execute tar -xf "$TMP_DIR/$archive_name" -C "$TMP_DIR" "$bin"
	
	safe_mkdir "$LOCAL_BIN_DIR"
	safe_execute mv "$TMP_DIR/$bin" "$LOCAL_BIN_DIR/$bin"
   
	success "Lazygit installed successfully in $LOCAL_BIN_DIR"
}
