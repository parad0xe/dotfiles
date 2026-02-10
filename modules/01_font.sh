#!/bin/bash

module_check() {
    local font_path="$LOCAL_FONT_DIR/JetBrainsMonoNLNerdFont-Thin.ttf"
    if ! file_exists "$font_path"; then
        return $RET_MODULECHECK_REQUIRE_INSTALL
    fi

    return $RET_MODULECHECK_DONOTHING
}

module_install() {
    header "Installing nerdfont (JetBrainsMono)"

    info "Preparing installation..."
	ensure_has_command "wget"
	ensure_has_command "unzip"

	local version
	version=$(get_github_latest_release "ryanoasis/nerd-fonts")
	
	step "Detected latest version: $version"

	safe_mkdir -p "$TMP_DIR/nerd-font" "$LOCAL_FONT_DIR"

	blank
	info "Downloading JetBrainsMono archive..."
	safe_execute wget -qP "$TMP_DIR/nerd-font" "https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/JetBrainsMono.zip"

	blank
	info "Extracting and installing fonts..."
	safe_execute unzip -q "$TMP_DIR/nerd-font/JetBrainsMono.zip" -d "$TMP_DIR/nerd-font"
	
	step "Moving fonts to $LOCAL_FONT_DIR"
	safe_execute mv "$TMP_DIR/nerd-font/"*.ttf "$LOCAL_FONT_DIR/"

    blank
    success "Nerdfont installed successfully"
}

module_configure() {
    header "Configuring fonts"
    
    info "Updating system font cache..."
    safe_execute fc-cache -f

    blank
    success "Font cache updated successfully"
}
