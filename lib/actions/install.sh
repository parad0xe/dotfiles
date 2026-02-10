#!/bin/bash

configure_bin_scripts_assets() {
    header "Configuring bin & scripts assets"
    
    info "Synchronizing custom scripts..."
	
	blank
    safe_link_all "$ASSETS_DIR/common/bin" "$LOCAL_BIN_DIR"

	blank
    safe_link_all "$ASSETS_DIR/common/scripts" "$LOCAL_BIN_DIR"
}

install() {
    load_all_modules

    configure_bin_scripts_assets

    safe_execute rm -rf "$TMP_DIR"

    blank
    success "Installation complete"
    tips "Restart your shell and run :PlugInstall inside nvim"
}
