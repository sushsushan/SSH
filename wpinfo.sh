#!/bin/bash

# Clear the screen
clear

# Find all directories containing wp-config.php files (assuming they are WordPress installations)
wp_dirs=$(find "$(pwd)" -type f -name 'wp-config.php' -exec dirname {} \;)

# Check if any WordPress installations are found
if [ -z "$wp_dirs" ]; then
    echo "No WordPress installations found in the current directory."
    exit 0
fi

# Initialize installation count
installations_found=0

# Display header information
echo "-----------------------------------------------------------"
echo "             WordPress Installations Information           "
echo "-----------------------------------------------------------"

# Loop through each WordPress installation directory
for dir in $wp_dirs; do
    # Increment installation count
    ((installations_found++))

    # Display information for each site
    echo -e "\n-----------------------------------------------------------"
    echo -e "WordPress Installation Found in: $dir"
    echo "-----------------------------------------------------------"

    # Check if wp-config.php exists in the directory
    if [ ! -f "$dir/wp-config.php" ]; then
        echo "Error: wp-config.php not found in $dir. Skipping this directory."
        continue
    fi

    # Navigate to the WordPress installation directory using a subshell
    (
        cd "$dir" || exit

        # Check if wp-cli is installed
        if ! command -v wp &>/dev/null; then
            echo "Error: wp-cli is not installed. Unable to retrieve site information."
            exit 1
        fi

        # Get site URL and home URL from wp-cli
        siteurl=$(wp option get siteurl --quiet 2>/dev/null)
        homeurl=$(wp option get home --quiet 2>/dev/null)

        # Validate site URL and home URL
        if [ -z "$siteurl" ]; then
            siteurl="Not found"
        fi
        if [ -z "$homeurl" ]; then
            homeurl="Not found"
        fi

        # Get database details from wp-config.php
        db_name=$(grep -o "define( *'DB_NAME', *'\([^']*\)'" wp-config.php | sed "s/define( *'DB_NAME', *'\([^']*\)'/\1/")
        db_user=$(grep -o "define( *'DB_USER', *'\([^']*\)'" wp-config.php | sed "s/define( *'DB_USER', *'\([^']*\)'/\1/")
        db_password=$(grep -o "define( *'DB_PASSWORD', *'\([^']*\)'" wp-config.php | sed "s/define( *'DB_PASSWORD', *'\([^']*\)'/\1/")
        db_host=$(grep -o "define( *'DB_HOST', *'\([^']*\)'" wp-config.php | sed "s/define( *'DB_HOST', *'\([^']*\)'/\1/")
        db_collate=$(grep -o "define( *'DB_COLLATE', *'\([^']*\)'" wp-config.php | sed "s/define( *'DB_COLLATE', *'\([^']*\)'/\1/")
        db_prefix=$(grep -o "table_prefix.*'" wp-config.php | sed "s/table_prefix.*'\([^']*\)'.*/\1/")

        # Check for empty database variables
        db_name=${db_name:-"Not found"}
        db_user=${db_user:-"Not found"}
        db_password=${db_password:-"Not found"}
        db_host=${db_host:-"Not found"}
        db_collate=${db_collate:-"Not found"}
        db_prefix=${db_prefix:-"Not found"}

        # Get disk usage
        disk_usage=$(du -sh . | cut -f1)

        # Display formatted information
        echo -e "Site URL: $siteurl"
        echo -e "Home URL: $homeurl"
        echo "-----------------------------------------------------------"
        echo "Database Details:"
        echo -e "  - Database Name: $db_name"
        echo -e "  - Database User: $db_user"
        echo -e "  - Database Password: $db_password"
        echo -e "  - Database Host: $db_host"
        echo -e "  - Database Collate: $db_collate"
        echo -e "  - Table Prefix: $db_prefix"
        echo "-----------------------------------------------------------"
        echo "Disk Usage: $disk_usage"
        echo "-----------------------------------------------------------"
    )
done

# Display the total number of installations found
echo -e "\n-----------------------------------------------------------"
echo "Total WordPress Installations Found: $installations_found"
echo "-----------------------------------------------------------"
