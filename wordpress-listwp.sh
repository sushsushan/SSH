#!/bin/bash

# Define colors for formatting
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RESET="\e[0m"

# Get the current user's home directory
USER_HOME=$(eval echo ~$(whoami))

# Find all WordPress installations by locating wp-config.php
WP_CONFIG_FILES=$(find "$USER_HOME" -type f -name "wp-config.php" 2>/dev/null)

# If no WordPress installations are found
if [[ -z "$WP_CONFIG_FILES" ]]; then
    echo -e "${YELLOW}No WordPress installations found.${RESET}"
    exit 1
fi

# Print header
echo -e "${GREEN}--------------------------------------------------------------${RESET}"
echo -e "${CYAN}Detected WordPress Installations:${RESET}"
echo -e "${GREEN}--------------------------------------------------------------${RESET}"
printf "%-40s | %-30s | %-15s | %-15s | %-15s | %-10s\n" "Path" "Site URL" "DB Name" "DB User" "DB Password" "Prefix"
echo -e "${GREEN}----------------------------------------------------------------------------------------------------------------${RESET}"

# Initialize counter
WP_COUNT=0

# Loop through each found wp-config.php
while IFS= read -r wp_config; do
    # Extract installation path
    WP_PATH=$(dirname "$wp_config")

    # Extract details from wp-config.php
    DB_NAME=$(grep -oP "(?<=define\('DB_NAME', ').*?(?='\))" "$wp_config")
    DB_USER=$(grep -oP "(?<=define\('DB_USER', ').*?(?='\))" "$wp_config")
    DB_PASS=$(grep -oP "(?<=define\('DB_PASSWORD', ').*?(?='\))" "$wp_config")
    PREFIX=$(grep -oP "(?<=\$table_prefix = ').*?(?=';)" "$wp_config")

    # Extract home URL and site URL from database using WP-CLI (if available)
    if command -v wp &>/dev/null; then
        SITE_URL=$(wp option get siteurl --path="$WP_PATH" --allow-root 2>/dev/null)
        HOME_URL=$(wp option get home --path="$WP_PATH" --allow-root 2>/dev/null)
    else
        SITE_URL="WP-CLI not found"
        HOME_URL="WP-CLI not found"
    fi

    # Print data in table format
    printf "%-40s | %-30s | %-15s | %-15s | %-15s | %-10s\n" "$WP_PATH" "$SITE_URL" "$DB_NAME" "$DB_USER" "$DB_PASS" "$PREFIX"

    # Increment WordPress installation count
    ((WP_COUNT++))

done <<< "$WP_CONFIG_FILES"

# Print footer with total count
echo -e "${GREEN}----------------------------------------------------------------------------------------------------------------${RESET}"
echo -e "${CYAN}Total WordPress Installations Found: $WP_COUNT${RESET}"
