#!/bin/bash

set -x

# Get current directory
cur_dir=$(pwd)
src_dir="/src"

# Go to source code
cd $src_dir

# If the version number is not an empty string
if [ -n "$VERSION_TAG" ]; then
  # If NOT the tag is "nightly"...
  if [ "$VERSION_TAG" != "nightly" ]; then
    # Use the version number as a tag to checkout
    git checkout -b $VERSION_TAG $VERSION_TAG
  fi
fi

# Go back to the original directory
cd $cur_dir