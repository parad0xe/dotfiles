#!/bin/bash

is_empty() {
	[[ -z "$1" ]]
}

is_not_empty() {
	[[ -n "$1" ]]
}

file_exists() {
	[[ -f "$1" ]]
}

non_empty_file() {
	[[ -s "$1" ]]
}

dir_exists() {
	[[ -d "$1" ]]
}

ensure_has_file() {
	if dry_run; then
		return $RETOK
	fi
	if ! file_exists "$1"; then
		err "File $1 not found"
		exit $RETERR
	fi
}

can_read() {
	ensure_has_file "$1"
	[[ -r "$1" ]]
}

safe_mkdir() {
    for dir in "$@"; do
        if dry_run; then
            dry "mkdir -p $dir"
        else
            mkdir -p "$dir"
        fi
    done
}

safe_link_all() {
    local src="$1"
    local dst="$2"
   
    info "Linking $(basename "$src") to $dst"
    safe_mkdir "$dst"
    
    for item in "$src"/*; do
        [ -e "$item" ] || continue
        safe_link "$item" "$dst/$(basename "$item")"
    done
}

safe_link() {
    local src="$1" dst="$2"

    if [ -e "$dst" ] || [ -L "$dst" ]; then
        if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
            return
        fi
        backup_file "$dst"
    fi

    safe_mkdir "$(dirname "$dst")"
    safe_execute ln -Tsf "$src" "$dst"
	
	if ! dry_run; then
		step "link: $dst"
	fi
}

backup_file() {
    local target="$1"

    if [ ! -e "$target" ] && [ ! -L "$target" ]; then
        return
    fi

    local rel_path="${target#$HOME/}"
    rel_path="${rel_path#/}"
    
    local dest_backup="$BACKUP_DIR/$rel_path"
    
    safe_mkdir "$(dirname "$dest_backup")" 
    safe_execute mv "$target" "$dest_backup"

	if ! dry_run; then
    	muted "Backup created: -> $dest_backup"
	fi
}
