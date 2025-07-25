#!/bin/bash

# for config_dir in */; do 
#     config_dir=${config_dir%*/}
#     echo "Grabbing current $config_dir config..."; 
#     cp --interactive --recursive --verbose "$HOME/.config/$config_dir" . 
#     echo "Done!"
# done

# echo "Successfully moved all configuration files over."

config_dir="$HOME/.config"
repo_config_dir="."
all_found_dirs=()

# Keeps track of the different categories of configuration files
editor_dirs=("nvim")
found_editor_dirs=()
hyprland_dirs=("hypr" "kitty" "waybar")
found_hyprland_dirs=()

for sub1 in "$config_dir"/*/; do
    # Remove trailing slash
    folder="${sub1%/}"
    # Extract just the folder name
    folder="${folder##*/}"
    if [ -d "$repo_config_dir/$folder" ]; then
        all_found_dirs+=("$folder")
    fi
done

# Checks for editor configs in the current home directory
for dir in "${all_found_dirs[@]}"; do
    # Remove trailing slash
    folder="${dir%/}"
    # Extract just the folder name
    folder="${folder##*/}"
    
    for editor_dir in "${editor_dirs[@]}"; do
        if [[ "$folder" == "$editor_dir" ]]; then
            found_editor_dirs+=("$folder")
        fi
    done
done

# Checks for Hyprland configs in the current home directory
for dir in "${all_found_dirs[@]}"; do
    # Remove trailing slash
    folder="${dir%/}"
    # Extract just the folder name
    folder="${folder##*/}"
    
    for hyprland_dir in "${hyprland_dirs[@]}"; do
        if [[ "$folder" == "$hyprland_dir" ]]; then
            found_hyprland_dirs+=("$folder")
        fi
    done
done

if [ ${#found_editor_dirs[@]} -eq 0 ]; then 
    echo "No editor configs found!"
else
    echo "Found editor config directories: ${found_editor_dirs[@]}"

    while true; do
        read -rp "Copy current editor configs over to repository: (y/N) " copy_editor_config
        copy_editor_config="${copy_editor_config,,}"
        if [ -z "$copy_editor_config" ]; then
            copy_editor_config="n"
        fi

        case $copy_editor_config in [[yn]) break ;; *) echo "Invalid input, must choose y/n";; esac
    done

    if [ "$copy_editor_config" = "n" ]; then
        echo "Skipping copying over editor configs!"
    fi
fi
echo

if [ ${#found_hyprland_dirs[@]} -eq 0 ]; then 
    echo "No Hyprland configs found!"
else
    echo "Found Hyprland config directories: ${found_hyprland_dirs[@]}"

    while true; do
        read -rp "Copy current Hyperland configs over to repository: (y/N) " copy_hyprland_config
        copy_hyprland_config="${copy_hyprland_config,,}"
        if [ -z "$copy_hyprland_config" ]; then
            copy_hyprland_config="n"
        fi
        case $copy_hyprland_config in [[yn]) break ;; *) echo "Invalid input, must choose y/n";; esac
    done
    
    if [ "$copy_hyprland_config" = "n" ]; then
        echo "Skipping copying over Hyprland configs!"
    fi
fi
echo

# Enable globbing for file checking
shopt -s nullglob dotglob

if [ "$copy_editor_config" = "y" ]; then
    for dir in "${found_editor_dirs[@]}"; do 
        echo "Grabbing current $dir config..."; 
        # Grabbing all files in the current dir
        files=("$config_dir/$dir"/*)
        # Checks to see if there are no files in the current dir
        if [ "${#files[@]}" -eq 0 ]; then
            echo "$dir is empty. Skipping!"
        else
            cp --interactive --recursive --verbose "$config_dir/$dir" "$repo_config_dir/"
            echo "Done!"
        fi
    done
    echo
fi

if [ "$copy_hyprland_config" = "y" ]; then
    for dir in "${found_hyprland_dirs[@]}"; do 
        echo "Grabbing current $dir config..."; 
        # Grabbing all files in the current dir
        files=("$config_dir/$dir"/*)
        # Checks to see if there are no files in the current dir
        if [ "${#files[@]}" -eq 0 ]; then
            echo "$dir is empty. Skipping!"
        else
            cp --interactive --recursive --verbose "$config_dir/$dir" "$repo_config_dir/"
            echo "Done!"
        fi
    done
    echo
fi

# Clean up to abide by best practices
shopt -u nullglob dotglob

echo "Done grabbing configs!"
