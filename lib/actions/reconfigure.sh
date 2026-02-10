#!/bin/bash

reconfigure() {
    load_all_modules

    safe_execute rm -rf "$TMP_DIR"

    blank
    success "Reconfiguration complete"
    tips "Restart your shell and run :PlugInstall inside nvim"
}
