#!/bin/bash

set -euo pipefail

RUN_COMMAND=""
FORCE_CONFIRMATION="false"
DRY_RUN="false"
VERBOSE=1
TARGET_SHELL=""
TARGET_SHELL_RC=""

readonly PROJECT_ROOT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
readonly TMP_DIR="$(mktemp -d)"
readonly ASSETS_DIR="$PROJECT_ROOT_DIR/assets"
readonly LOCAL_BIN_DIR="${HOME}/.local/bin"
readonly LOCAL_FONT_DIR="${HOME}/.local/share/fonts"
readonly JUNEST_DIR="$HOME/.local/share/junest"
readonly JUNEST_EXEC_DIR="$HOME/.local/share/junest/bin"
readonly JUNEST_ROOT_DIR="$HOME/.junest"
readonly JUNEST_BIN_DIR="$JUNEST_ROOT_DIR/bin"
readonly JUNEST_BIN_WRAPPERS_DIR="$JUNEST_ROOT_DIR/usr/bin_wrappers"
readonly BACKUP_DIR="${HOME}/.local/state/dotfiles_backups/$(date +%Y%m%d_%H%M%S)"

readonly RETOK=0
readonly RETERR=1

readonly RET_MODULECHECK_REQUIRE_INSTALL=0
readonly RET_MODULECHECK_DONOTHING=1

force_confirm() {
	[[ "${FORCE_CONFIRMATION:-false}" = "true" ]]
}

dry_run() {
	[[ "${DRY_RUN:-false}" = "true" ]]
}

verbose() {
	echo ${VERBOSE:-1}
}


shopt -s nullglob

for core_lib in "${PROJECT_ROOT_DIR}/lib/core/"*.sh; do
    source "$core_lib"
done

for action_lib in "${PROJECT_ROOT_DIR}/lib/actions/"*.sh; do
    source "$action_lib"
done

shopt -u nullglob

usage() {
	blank
	log "Usage: $0 [-yjdvhs] {install|reinstall|reconfigure|uninstall}"
	log "	-y|--yes         force all confirmations"
	log "	-d|--dry-run     simulate setup"
	log "	-s|--shell       target shell (bash|zsh|fish)"
	log "	-v|--verbose     verbose output"
	log "	-h|--help        print this help"
	exit $RETERR
}

setup_shell_env() {
	if is_not_empty "$TARGET_SHELL"; then
        if [[ ! "$TARGET_SHELL" =~ ^(bash|zsh|fish)$ ]]; then
            warn "Invalid shell '$TARGET_SHELL' provided. Reverting to detection."
            TARGET_SHELL=""
        fi
    fi

	if is_empty "$TARGET_SHELL"; then
        local detected_shell
        detected_shell=$(basename "${SHELL:-bash}")

        if force_confirm; then
            TARGET_SHELL="$detected_shell"
        else
            info "Please select the shell you want to configure:"
            local default_idx=1
            [[ "$detected_shell" == "zsh" ]] && default_idx=2
            [[ "$detected_shell" == "fish" ]] && default_idx=3

            printf "Available: (1) bash, (2) zsh, (3) fish [Default: $detected_shell]: "
            read -r choice
            case "$choice" in
                1|bash) TARGET_SHELL="bash" ;;
                2|zsh)  TARGET_SHELL="zsh" ;;
                3|fish) TARGET_SHELL="fish" ;;
                *)      TARGET_SHELL="$detected_shell" ;;
            esac
        fi
    fi
    
	case "$TARGET_SHELL" in
		bash) TARGET_SHELL_RC="$HOME/.bashrc" ;;
		zsh)  TARGET_SHELL_RC="$HOME/.zshrc" ;;
		fish) TARGET_SHELL_RC="$HOME/.config/fish/config.fish" ;;
		*) fatal "Unsupported shell: $TARGET_SHELL. No configuration file found." ;;
	esac

    success "Target shell set to: $TARGET_SHELL"
	success "Target configuration file identified: $TARGET_SHELL_RC"
}

load_all_modules() {
    shopt -s nullglob

	for module in "${PROJECT_ROOT_DIR}/modules"/*.sh; do
		module_init() { return $RETOK; }
		module_check() { return $RET_MODULECHECK_DONOTHING; }
		module_install() { return $RETOK; }
		module_configure() { return $RETOK; }


        if can_read "$module"; then
			source "$module"

			case "$RUN_COMMAND" in
				install)
					module_init
					if module_check; then
						module_install
						module_configure
					fi
					;;
				reinstall)
					module_init
					module_install
					module_configure
					;;
				reconfigure)
					module_init
					if ! module_check; then
						module_configure
					fi
					;;
			esac
		else
			fatal "Module $module cannot be read."
		fi
		
		unset -f module_init module_check module_install module_configure
	done
    
    shopt -u nullglob
}

target_shell_is() {
	[[ "$TARGET_SHELL" == "$1" ]]
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -y|--yes) FORCE_CONFIRMATION="true"; shift ;;
        -d|--dry-run) DRY_RUN="true"; shift ;;
		-s|--shell) 
            if [[ -n "${2:-}" ]]; then
                TARGET_SHELL="$2"
                shift 2
            else
                fatal "--shell requires an argument (bash|zsh|fish)"
            fi
            ;;
        -v|--verbose) VERBOSE=2; shift ;;
        -h|--help) usage ;;
        install|reinstall|reconfigure|uninstall) 
			if ! is_empty "$RUN_COMMAND"; then
				usage
			fi

			RUN_COMMAND="$1"
			shift
			;;
        *) usage ;;
    esac
done

detect_os

if [[ "$RUN_COMMAND" =~ ^install|reinstall|reconfigure$ ]]; then
    setup_shell_env
fi

readonly ARCH=$(uname -m)
readonly IS_VERBOSE=$([ "$(verbose)" == "2" ] && echo "true" || echo "false")

header \
    "Runtime configuration" \
    "" \
    "User            : $USER" \
    "OS              : $ID ($ARCH)" \
    "Target shell    : ${TARGET_SHELL:-none}" \
    "Target shell RC : ${TARGET_SHELL_RC:-none}" \
    "Command         : $RUN_COMMAND" \
    "Force confirms  : $FORCE_CONFIRMATION" \
    "Dry run         : $DRY_RUN" \
    "Verbose         : $IS_VERBOSE" \
    "" \
    "Directories" \
    "Project root   : $PROJECT_ROOT_DIR" \
    "Assets         : $ASSETS_DIR" \
    "Backup folder  : $BACKUP_DIR" \
    "Local fonts    : $LOCAL_FONT_DIR"

case $RUN_COMMAND in
	install|reinstall) install ;;
	reconfigure) reconfigure ;;
	uninstall) uninstall ;;
	*) usage ;;
esac
