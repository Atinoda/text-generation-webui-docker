#!/bin/bash

# Note starting directory
cur_dir=$(pwd)

# Specify the directory containing the top-level folders
directory="/app/extensions"

# Iterate over the extensions passed in args
for extension in "$@"; do
    echo $extension
    folder="$directory/$extension"
    if [ -d "$folder" ]; then
        # Change directory to the current folder
        cd "$folder"

        # Check if requirements.txt file exists
        if [ -f "requirements.txt" ]; then
            echo "Live installing requirements for $folder..."
            pip3 install -r requirements.txt
            echo "Requirements installed in $folder"
        else
            echo "Skipping live install of $folder: requirements.txt not found"
        fi

        # Change back to the original directory
        cd "$directory"
    fi
done

# Return to starting directory
cd $cur_dir
