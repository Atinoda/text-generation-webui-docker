#!/bin/bash

set -x

# Get current directory
cur_dir=$(pwd)
exlv2_dir="/venv/lib/python3.10/site-packages/exllamav2/"

# Go to exl directory
cd $exlv2_dir

# Apply patch
patch -i /scripts/exllama_version_fix.patch

# Go back to the original directory
cd $cur_dir
