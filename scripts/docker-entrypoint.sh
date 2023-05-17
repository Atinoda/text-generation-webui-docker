#!/bin/bash

# Function to handle keyboard interrupt
function ctrl_c {
    echo -e "\nKilling container!"
    # Add your cleanup actions here
    exit 0
}
# Register the keyboard interrupt handler
trap ctrl_c SIGTERM SIGINT SIGQUIT SIGHUP

# Generate default configs if empty
CONFIG_DIRECTORIES=("loras" "models" "presets" "prompts" "softprompts" "training")
for config_dir in "${CONFIG_DIRECTORIES[@]}"; do
  if [ -z "$(ls -A /app/"$config_dir")" ]; then
    cp -ar /src/"$config_dir" /app/
    chown -R 1000:1000 /app/"$config_dir"  # Not ideal... but convenient.
  fi
done

# Print variant
VARIANT=$(cat /variant.txt)
echo "=== Running text-generation-webui variant: '$VARIANT' ===" 

# Print version freshness
cur_dir=$(pwd)
src_dir="/src"
cd $src_dir
git fetch origin >/dev/null 2>&1
if [ $? -ne 0 ]; then
  # An error occurred
  COMMITS_BEHIND="UNKNOWN"
else
  # The command executed successfully
  COMMITS_BEHIND=$(git rev-list HEAD..origin --count)
fi
echo "=== (This version is $COMMITS_BEHIND commits behind origin) ===" 
cd $cur_dir

# Assemble CMD and extra launch args
eval "extra_launch_args=($EXTRA_LAUNCH_ARGS)"
LAUNCHER=($@ $extra_launch_args)

# Launch the server with ${CMD[@]} + ${EXTRA_LAUNCH_ARGS[@]}
"${LAUNCHER[@]}"
