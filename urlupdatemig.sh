#!/bin/bash

set -e

# Function to get database details from wp-config.php
get_db_details() {
    local config_file="$1"
    DB_NAME=$(grep -oP "(?<=define\('DB_NAME', ').*?(?='\);)" "$config_file")
    DB_USER=$(grep -oP "(?<=define\('DB_USER', ').*?(?='\);)" "$config_file")
    DB_PASS=$(grep -oP "(?<=define\('DB_PASSWORD', ').*?(?='\);)" "$config_file")
    DB_HOST=$(grep -oP "(?<=define\('DB_HOST', ').*?(?='\);)" "$config_file")
    SITE_URL=$(grep -oP "(?<=define\('WP_HOME', ').*?(?='\);)" "$config_file" || echo "Unknown")
    echo "Database Name: $DB_NAME"
    echo "Database User: $DB_USER"
    echo "Database Password: $DB_PASS"
    echo "Site URL: $SITE_URL"
}

# Confirming WordPress Path
read -p "Enter the absolute path to your WordPress installation: " WP_PATH
if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "Error: wp-config.php not found in the specified path. Exiting."
    exit 1
fi

get_db_details "$WP_PATH/wp-config.php"

# Confirm database backup
read -p "Would you like to backup the database before proceeding? (y/n): " backup_choice
if [[ "$backup_choice" =~ ^[Yy]$ ]]; then
    mkdir -p ~/backup
    BACKUP_FILE=~/backup/${DB_NAME}_$(date +"%Y%m%d_%H%M%S").sql
    echo "Creating backup..."
    mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE"
    echo "Backup completed: $BACKUP_FILE"
fi

# Confirm URL update
read -p "Would you like to update the site URLs? (y/n): " update_choice
if [[ "$update_choice" =~ ^[Yy]$ ]]; then
    read -p "Enter the new site URL (e.g., https://newdomain.com): " NEW_URL
    
    # Updating URLs in the database
    TEMP_DB_USER="$(whoami)_$(openssl rand -hex 4)"
    TEMP_DB_PASS=$(openssl rand -base64 12)
    echo "Creating temporary database user..."
    uapi Mysql create_user name="$TEMP_DB_USER" password="$TEMP_DB_PASS"
    uapi Mysql set_privileges_on_database database="$DB_NAME" user="$TEMP_DB_USER" privileges="ALL PRIVILEGES"
    
    echo "Updating URLs in database..."
    mysql -u "$TEMP_DB_USER" -p"$TEMP_DB_PASS" -D "$DB_NAME" -e "
        UPDATE wp_options SET option_value = REPLACE(option_value, '$SITE_URL', '$NEW_URL') WHERE option_name IN ('siteurl', 'home');
        UPDATE wp_posts SET guid = REPLACE(guid, '$SITE_URL', '$NEW_URL');
        UPDATE wp_posts SET post_content = REPLACE(post_content, '$SITE_URL', '$NEW_URL');
        UPDATE wp_postmeta SET meta_value = REPLACE(meta_value, '$SITE_URL', '$NEW_URL');
    "
    
    # WP-CLI for additional updates
    if command -v wp &> /dev/null; then
        echo "Updating URLs using WP-CLI..."
        wp search-replace "$SITE_URL" "$NEW_URL" --path="$WP_PATH" --all-tables
    fi
    
    # Remove temporary DB user
    uapi Mysql delete_user name="$TEMP_DB_USER"
    echo "URL update completed."
fi

echo "Migration process completed successfully."
