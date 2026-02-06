#!/bin/bash

uninstall_junest() {
	display_header "JuNest uninstallation"

	local targets=(
        "$HOME/.junest"
        "$JUNEST_ROOT"
    )
	local found=()
	for dir in "${targets[@]}"; do
        if [ -d "$dir" ]; then
            found+=("$dir")
        fi
    done
	
	if [ ${#found[@]} -ne 0 ]; then
		echo "The following directories will be permanently removed:"
		for dir in "${found[@]}"; do
			if [ -d "$dir" ]; then
				echo "  - $dir"
			fi
		done

		echo ""
		if [ "${FORCE:-false}" = true ] || confirm "Uninstall JuNest ?"; then
			echo -e "\n--> Removing JuNest environments..."
			for dir in "${targets[@]}"; do
				if [ -d "$dir" ]; then
					echo "  - Deleting: $dir"
					rm -rf "$dir"
				fi
			done
			
			echo -e "\nJuNest uninstalled successfully."
		else
			echo -e "[Aborted] skip.."
		fi
	else
			echo -e "JuNest not installed."
	fi
}

uninstall_fish() {
	display_header "Fish uninstallation"

	if [ -f "$(which fish)" ]; then
		echo "The following program will be permanently removed:"
		echo "  - fish"

		echo ""
		if [ "${FORCE:-false}" = true ] || confirm "Uninstall fish ?"; then
			echo -e "\n--> Removing Fish environments..."
			echo "  - Deleting: fish"
			pkg_uninstall fish
			rm -rf "$HOME/.config/fish"
			
			echo -e "\nFish uninstalled successfully."
		else
			echo -e "[Aborted] skip.."
		fi
	else
			echo -e "Fish not installed."
	fi
}

uninstall_pyenv() {
	display_header "Pyenv uninstallation"
	local targets=(
        "$HOME/.pyenv"
    )
	local found=()
	for dir in "${targets[@]}"; do
        if [ -d "$dir" ]; then
            found+=("$dir")
        fi
    done
	
	if [ ${#found[@]} -ne 0 ]; then
		echo "The following directories will be permanently removed:"
		for dir in "${found[@]}"; do
			if [ -d "$dir" ]; then
				echo "  - $dir"
			fi
		done

		echo ""
		if [ "${FORCE:-false}" = true ] || confirm "Uninstall Pyenv ?"; then
			echo -e "\n--> Removing Pyenv environments..."
			for dir in "${targets[@]}"; do
				if [ -d "$dir" ]; then
					echo "  - Deleting: $dir"
					rm -rf "$dir"
				fi
			done
			
			echo -e "\nPyenv uninstalled successfully."
		else
			echo -e "[Aborted] skip.."
		fi
	else
			echo -e "Pyenv not installed."
	fi
}

uninstall() {
	if [ -d "$HOME/.junest" ]; then
		uninstall_fish
		uninstall_pyenv
		uninstall_junest
		
		echo -e "\n[SUCCESS] Uninstallation complete."
	else
		echo -e "\nNothing to uninstall."
	fi
}
