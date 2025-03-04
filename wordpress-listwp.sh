#!/bin/bash

# Define colors for formatting
GREEN="\e[32m"
YELLOW="\e[33m"
CYAN="\e[36m"
RED="\e[31m"
BOLD="\e[1m"
RESET="\e[0m"

# Get the current user's home directory
USER_HOME=$(eval echo ~$(whoami))

# Find all WordPress installations by locating wp-config.php
WP_CONFIG_FILES=$(find "$USER_HOME" -type f -name "wp-config.php" 2>/dev/null)

# If no WordPress installations are found
if [[ -z "$WP_CONFIG_FILES" ]]; then
    echo -e "${RED}No WordPress installations found.${RESET}"
    exit 1
fi

# Print header
echo -e "${BOLD}${GREEN}================================================================================================================================================${RESET}"
echo -e "${CYAN}${BOLD}                                    WordPress Installations Found on Your System${RESET}"
echo -e "${BOLD}${GREEN}================================================================================================================================================${RESET}"

# Print table header with fixed column widths
printf "${BOLD}${YELLOW}%-4s | %-40s | %-35s | %-35s | %-15s | %-15s | %-10s | %-10s${RESET}\n" \
    "No." "Installation Path" "Site URL" "Home URL" "DB Name" "DB User" "Prefix" "Version"
echo -e "${GREEN}------------------------------------------------------------------------------------------------------------------------------------------------${RESET}"

# Initialize counter
WP_COUNT=0

# Loop through each found wp-config.php
while IFS= read -r wp_config; do
    # Increment WordPress installation count
    ((WP_COUNT++))

    # Extract installation path
    WP_PATH=$(dirname "$wp_config")

    # Extract database details using grep
    DB_NAME=$(grep "DB_NAME" "$wp_config" | cut -d "'" -f4 || echo "N/A")
    DB_USER=$(grep "DB_USER" "$wp_config" | cut -d "'" -f4 || echo "N/A")
    DB_PASS=$(grep "DB_PASSWORD" "$wp_config" | cut -d "'" -f4 || echo "N/A")

    # Extract table prefix
    PREFIX=$(grep "\$table_prefix" "$wp_config" | cut -d "'" -f2 || echo "N/A")

    # Extract site and home URL using WP-CLI
    if command -v wp &>/dev/null; then
        SITE_URL=$(wp option get siteurl --path="$WP_PATH" --allow-root 2>/dev/null || echo "N/A")
        HOME_URL=$(wp option get home --path="$WP_PATH" --allow-root 2>/dev/null || echo "N/A")
        WP_VERSION=$(wp core version --path="$WP_PATH" --allow-root 2>/dev/null || echo "N/A")
    else
        SITE_URL="WP-CLI not found"
        HOME_URL="WP-CLI not found"
        WP_VERSION="WP-CLI not found"
    fi

    # Ensure values are not empty
    [[ -z "$DB_NAME" ]] && DB_NAME="N/A"
    [[ -z "$DB_USER" ]] && DB_USER="N/A"
    [[ -z "$DB_PASS" ]] && DB_PASS="N/A"
    [[ -z "$PREFIX" ]] && PREFIX="N/A"
    [[ -z "$SITE_URL" ]] && SITE_URL="N/A"
    [[ -z "$HOME_URL" ]] && HOME_URL="N/A"
    [[ -z "$WP_VERSION" ]] && WP_VERSION="N/A"

    # Print data in table format
    printf "${CYAN}%-4s ${RESET}| %-40s | %-35s | %-35s | %-15s | %-15s | %-10s | %-10s\n" \
        "$WP_COUNT" "$(echo $WP_PATH | cut -c1-40)" "$(echo $SITE_URL | cut -c1-35)" "$(echo $HOME_URL | cut -c1-35)" "$DB_NAME" "$DB_USER" "$PREFIX" "$WP_VERSION"

done <<< "$WP_CONFIG_FILES"

# Print footer with total count
echo -e "${GREEN}------------------------------------------------------------------------------------------------------------------------------------------------${RESET}"
echo -e "${BOLD}${YELLOW}Total WordPress Installations Found: ${WP_COUNT}${RESET}"
echo -e "${GREEN}================================================================================================================================================${RESET}"
