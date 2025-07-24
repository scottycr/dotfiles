#!/bin/bash

# echo "Grabbing current nvim config..."
# echo "Done!"

for config_dir in */; do 
    config_dir=${config_dir%*/}
    echo "Grabbing current $config_dir config..."; 
    cp --interactive --recursive --verbose "$HOME/.config/$config_dir" . 
    echo "Done!"
done

echo "Successfully moved all configuration files over."
