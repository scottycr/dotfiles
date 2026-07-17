#!/bin/bash

# === START VERSION CHECK ===
# Checks if bash version is compatible
if (( BASH_VERSINFO[0] < 4 || ( BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 3 ) )); then
    echo "This script requires Bash 4.3 or newer." >&2
    echo "Exiting the script!" >&2
    exit 1
fi
# === END VERSION CHECK ===


# === START GLOBALS ===
local_config_dir="$HOME/.config"
repo_config_dir="../config"
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

load_found_config_dirs() {
    local -n found_dirs="$1"
    local -n config_list="$2"
    local -n found_config_dirs="$3"
    found_config_dirs=()

    for found_dir in "${found_dirs[@]}"; do
        # Remove trailing slash
        found_dir="${found_dir%/}"
        # Extract just the folder name
        found_dir="${found_dir##*/}"

        for config_dir in "${config_list[@]}"; do
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
        echo "No $config_category configs found!"
    else
        echo "Found $config_category config directories: ${found_config_dirs[@]}"
        
        while true; do
            read -rp "Copy current $config_category configs over to repository: (y/N) " copy_config
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
# Grabs the different config categories from the config_lists folder
config_categories=()
for file in "$config_lists_dir"/*; do
    # Extract just the file name
    category="${file##*/}"
    # Extract just the category name
    category="${category%%_*}"

    # Declare the necessary variables 
    config_categories+=("$category")
    declare -g "${category}_file"="$file"
    declare -g "${category}_dirs"
    declare -g "${category}_found_dirs"
done

# Grabs the various configs from each file in the config_lists folder
for category in "${config_categories[@]}"; do
    config_list_file="${category}_file"
    declare -n config_dirs="${category}_dirs"
    load_config_list ${!config_list_file} config_dirs $category
done
# # === END CONFIG CATEGORIES ===
 
 
# === START CONFIG DIRECTORY CHECKING ===
# Grabs all of the config directories for the current user
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

# Checks for matching configs in the current config directory
for category in "${config_categories[@]}"; do
    declare -n config_dirs="${category}_dirs"
    declare -n config_found_dirs="${category}_found_dirs"
    load_found_config_dirs all_found_dirs config_dirs config_found_dirs
done
# === END CONFIG DIRECTORY CHECKING ===
 
 
# === START CONFIG COPYING
for category in "${config_categories[@]}"; do
    declare -n config_found_dirs="${category}_found_dirs"
    copy_config_files config_found_dirs "$category"
done
# === END CONFIG COPYING
 
echo "Done grabbing configs!"
