#!/bin/bash

# Exit immediately on error, undefined variable, or pipe failure
set -euo pipefail

FORCE="false"
COMMAND=""

readonly PROJECT_ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)

readonly ASSETS="${PROJECT_ROOT}/assets"
readonly TMP="${PROJECT_ROOT}/tmp"
readonly BIN_DIR="${HOME}/.local/bin"
readonly FONT_DIR="${HOME}/.local/share/fonts"
readonly JUNEST_ROOT="${HOME}/.local/share/junest"

readonly OK=0
readonly ERR=1
readonly ERR_SUDO=2

source "${PROJECT_ROOT}/lib/utils.sh"
source "${PROJECT_ROOT}/lib/install.sh"
source "${PROJECT_ROOT}/lib/uninstall.sh"

# Distribution detection
if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "Error: Unable to detect distribution."
    exit $KO
fi

usage() {
	echo -e "Usage: $0 [-y] {install|uninstall}\n"
	exit $KO
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--yes) FORCE="true"; shift ;;
        install|uninstall) COMMAND="$1"; shift ;;
        *) usage ;;
    esac
done

case $COMMAND in
	install) install ;;
	uninstall) uninstall ;;
	*) usage ;;
esac
