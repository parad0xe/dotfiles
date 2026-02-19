#!/bin/bash

uninstall_junest() {
    header "Uninstalling junest"

    local targets=(
        "$JUNEST_ROOT_DIR"
        "$JUNEST_DIR"
    )
    local found=()
    for dir in "${targets[@]}"; do
        if [ -d "$dir" ]; then
            found+=("$dir")
        fi
    done
    
    if [ ${#found[@]} -ne 0 ]; then
        info "The following directories will be permanently removed:"
        for dir in "${found[@]}"; do
            step "$dir"
        done

        blank
        if force_confirm || confirm "Uninstall junest?"; then
            info "Removing junest environments..."
            for dir in "${targets[@]}"; do
                if [ -d "$dir" ]; then
					if ! dry_run; then
                    	step "Deleting $dir"
					fi
                    safe_execute rm -rf --no-preserve-root "$dir"
                fi
            done
            
            success "Junest uninstalled successfully"
        else
            warn "Uninstallation aborted"
        fi
    else
        info "Junest is not installed"
    fi
}

uninstall() {
    if [ -d "$JUNEST_ROOT_DIR" ] || [ -d "$JUNEST_DIR" ]; then
        uninstall_junest
        blank
        success "Uninstallation complete"
    else
        blank
        info "Nothing to uninstall"
    fi
}
