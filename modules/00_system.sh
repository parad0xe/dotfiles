#!/bin/bash

module_check() {
    return $RET_MODULECHECK_REQUIRE_INSTALL
}

module_install() {
    header "Installing system dependencies"

    info "Installing base development tools..."
    pkg_install --arch-only base-devel
    pkg_install --debian-only build-essential libssl-dev

    blank
    info "Installing core cli utilities..."
    pkg_install --both \
        fish python3 curl wget clang \
        llvm gcc unzip tar git man make which vim ncdu

    blank
    info "Installing sys utilities..."
    pkg_install --debian-only python3-pygments python3-venv libclang-dev openssh-server
    pkg_install --arch-only python-pygments python-virtualenv openssh

    blank
    success "System dependencies installed successfully"
}

module_configure() {
    return $RETOK
}
