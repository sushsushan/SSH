#!/bin/bash

# Function to generate a 4-digit random number
generate_random_number() {
    echo $((RANDOM % 9000 + 1000))
}

# Welcome message
echo "=============================================="
echo "  Welcome to the Advanced Staging Creton Tool "
echo "=============================================="
echo ""
echo "Staging is important because it allows you to test updates, new plugins, and changes without affecting your live website."
echo "This tool will create a staging copy of your WordPress site for safe testing."
echo ""

# List all installed WordPress directories
echo "Scanning for installed WordPress sites..."
WP_DIRS=($(find ~ -type d -name "wp-admin" -exec dirname {} \; 2>/dev/null))

if [[ ${#WP_DIRS[@]} -eq 0 ]]; then
    echo "No WordPress installations found in your home directory."
    exit 1
fi

echo "Found the following WordPress installations:"
for i in "${!WP_DIRS[@]}"; do
    echo "$((i+1)). ${WP_DIRS[$i]}"
done

# Ask user to select a directory
read -p "Enter the number corresponding to your WordPress installation: " selection
if ! [[ "$selection" =~ ^[0-9]+$ ]] || (( selection < 1 || selection > ${#WP_DIRS[@]} )); then
    echo "Invalid selection. Exiting."
    exit 1
fi

WP_PATH="${WP_DIRS[$((selection-1))]}"
echo "You selected: $WP_PATH"

# Confirm WordPress installation
if [[ ! -f "$WP_PATH/wp-config.php" ]]; then
    echo "Error: No WordPress installation detected in $WP_PATH"
    exit 1
fi

# Extract database credentials from wp-config.php
DB_NAME=$(grep -oP "(?<=DB_NAME', ').*?(?=')" "$WP_PATH/wp-config.php")
DB_USER=$(grep -oP "(?<=DB_USER', ').*?(?=')" "$WP_PATH/wp-config.php")
DB_PASS=$(grep -oP "(?<=DB_PASSWORD', ').*?(?=')" "$WP_PATH/wp-config.php")
SITE_URL=$(wp option get siteurl --path="$WP_PATH" 2>/dev/null)

echo ""
echo "======================================"
echo "  WordPress Installation Details"
echo "======================================"
echo "Site URL      : $SITE_URL"
echo "Database Name : $DB_NAME"
echo "DB Username   : $DB_USER"
echo "DB Password   : $DB_PASS"
echo "======================================"

# Confirm with the user before proceeding
read -p "Do you want to create a staging site? (yes/no): " confirm
if [[ "$confirm" != "yes" ]]; then
    echo "Operation cancelled."
    exit 1
fi

# Create staging directory
STAGING_DIR="$WP_PATH/staging"
mkdir -p "$STAGING_DIR"

# Generate a unique 4-digit folder
RANDOM_ID=$(generate_random_number)
STAGING_SUBDIR="$STAGING_DIR/$RANDOM_ID"
mkdir "$STAGING_SUBDIR"

# Copy files excluding existing staging directories
echo "Copying files to the staging site..."
rsync -av --exclude='staging' "$WP_PATH/" "$STAGING_SUBDIR/" --quiet

echo "======================================"
echo "  Staging Site Created Successfully!  "
echo "======================================"
echo "Path: $STAGING_SUBDIR"
echo "Now you can test your changes safely."
