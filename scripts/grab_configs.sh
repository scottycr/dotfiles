#!/bin/bash

# Checks if bash version is compatible
if (( BASH_VERSINFO[0] < 4 || ( BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 3 ) )); then
    echo "This script requires Bash 4.3 or newer." >&2
    exit 1
fi


# === START GLOBALS ===
local_config_dir="$HOME/.config"
repo_config_dir="../configs"
config_lists_dir="../config_lists"
# === END GLOBALS ===


# === START FUNCTIONS ===
load_config_list() {
    local config_list_file="$1"
    local -n config_list="$2"
    config_list=()
    local config_category="$3"
    
    # Checks to see if the provided configs list file exists
    if [ ! -f "$config_list_file" ]; then
        echo "Could not find $config_list_file in the config lists directory!"
        echo "This script will not be able to find any $config_category configs."
        return 1
    fi

    mapfile -t config_list < "$config_list_file"
}

load_config_dirs() {
    local -n found_dirs="$1"
    local -n config_dirs="$2"
    local -n found_config_dirs="$3"
    found_config_dirs=()

    for found_dir in "${found_dirs[@]}"; do
        # Remove trailing slash
        found_dir="${found_dir%/}"
        # Extract just the folder name
        found_dir="${found_dir##*/}"

        for config_dir in "${config_dirs[@]}"; do
            if [[ "$found_dir" == "$config_dir" ]]; then
                found_config_dirs+=("$found_dir")
            fi
        done
    done
}

copy_config_files() {
    local -n found_config_dirs="$1"
    local config_category="$2"

    if [ ${#found_config_dirs[@]} -eq 0 ]; then 
        echo "No editor configs found!"
    else
        echo "Found editor config directories: ${found_config_dirs[@]}"
        
        while true; do
            read -rp "Copy current editor configs over to repository: (y/N) " copy_config
            # Defaults to no if user does not provide any input
            if [ -z "$copy_config" ]; then
                copy_config="n"
            fi

            copy_config="${copy_config,,}"
            case $copy_config in [[yn]) break ;; *) echo "Invalid input, must choose y/n";; esac
        done

        if [ "$copy_config" = "y" ]; then
            # Enable globbing for file checking
            shopt -s nullglob dotglob

            for dir in "${found_config_dirs[@]}"; do
                echo "Grabbing current $dir config..."; 
                # Grabbing all files in the current dir
                files=("$local_config_dir/$dir"/*)
                # Checks to see if there are no files in the current dir
                if [ "${#files[@]}" -eq 0 ]; then
                    echo "$dir is empty. Skipping!"
                else
                    cp --interactive --recursive --verbose "$local_config_dir/$dir" "$repo_config_dir/"
                    echo "Done!"
                fi
            done

            # Clean up to abide by best practices
            shopt -u nullglob dotglob
        else
            echo "Skipping copying over $config_category configs!"
        fi
    fi
    echo

}
# === END FUNCTIONS ===


# === START CONFIG CATEGORIES ===
editor_dirs_file="$config_lists_dir/editor_configs.txt"
load_config_list "$editor_dirs_file" editor_dirs "editor"

hyprland_dirs_file="$config_lists_dir/hyprland_configs.txt"
load_config_list "$hyprland_dirs_file" hyprland_dirs "Hyprland"
# === END CONFIG CATEGORIES ===


# === START CONFIG DIRECTORY CHECKING ===
all_found_dirs=()
for dir in "$local_config_dir"/*/; do
    # Remove trailing slash
    dir="${dir%/}"
    # Extract just the folder name
    dir="${dir##*/}"
    if [ -d "$repo_config_dir/$dir" ]; then
        all_found_dirs+=("$dir")
    fi
done

# Checks for editor configs in the current config directory
load_config_dirs all_found_dirs editor_dirs found_editor_dirs
# Checks for Hyprland configs in the current config directory
load_config_dirs all_found_dirs hyprland_dirs found_hyprland_dirs
# === END CONFIG DIRECTORY CHECKING ===


# === START CONFIG COPYING
copy_config_files found_editor_dirs "editor"
copy_config_files found_hyprland_dirs "Hyprland"
# === END CONFIG COPYING

echo "Done grabbing configs!"
