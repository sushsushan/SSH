#!/bin/bash

# Find all directories containing wp-config.php files (assuming they are WordPress installations)
wp_dirs=$(find "$(pwd)" -type f -name 'wp-config.php' -exec dirname {} \;)


# Check if any WordPress installations are found
if [ -z "$wp_dirs" ]; then
    echo "No WordPress installations found."
    exit 0
fi


# Initialize installation count
installations_found=0


# Display header information once
echo "-------------------------------------------"
echo "WordPress Installations Information"
echo "-------------------------------------------"


# Loop through each WordPress installation directory
for dir in $wp_dirs; do
    # Increment installation count
    ((installations_found++))


    # Display information for each site
    echo "-------------------------------------------"
    echo "WordPress Installation in Path: $dir"


    # Navigate to the WordPress installation directory using a subshell
    (
        cd "$dir" || exit
        # Get site URL and home URL
        siteurl=$(wp option get siteurl 2>/dev/null)
        homeurl=$(wp option get home 2>/dev/null)


        # Get database details from wp-config.php
        db_name=$(grep -o "define( *'DB_NAME', *'\([^']*\)'" wp-config.php | sed "s/define( *'DB_NAME', *'\([^']*\)'/\1/")
        db_user=$(grep -o "define( *'DB_USER', *'\([^']*\)'" wp-config.php | sed "s/define( *'DB_USER', *'\([^']*\)'/\1/")
        db_password=$(grep -o "define( *'DB_PASSWORD', *'\([^']*\)'" wp-config.php | sed "s/define( *'DB_PASSWORD', *'\([^']*\)'/\1/")
        db_host=$(grep -o "define( *'DB_HOST', *'\([^']*\)'" wp-config.php | sed "s/define( *'DB_HOST', *'\([^']*\)'/\1/")
        db_collate=$(grep -o "define( *'DB_COLLATE', *'\([^']*\)'" wp-config.php | sed "s/define( *'DB_COLLATE', *'\([^']*\)'/\1/")
        db_prefix=$(grep -o "table_prefix.*'" wp-config.php | sed "s/table_prefix.*'\([^']*\)'.*/\1/")


        # Get disk usage
        disk_usage=$(du -sh . | cut -f1)


        # Display information in a more formatted way
        echo "Site URL: $siteurl"
        echo "Home URL: $homeurl"
        echo "-------------------------------------------"
        echo "Database Details:"
        echo "  - Database Name: $db_name"
        echo "  - Database User: $db_user"
        echo "  - Database Password: $db_password"
        echo "  - Database Host: $db_host"
        echo "  - Database Collate: $db_collate"
        echo "  - Table Prefix: $db_prefix"
        echo "-------------------------------------------"
        echo "Disk Usage: $disk_usage"
        echo "-------------------------------------------"
    )
done


# Display the total number of installations found
echo "Total WordPress Installations Found: $installations_found"
