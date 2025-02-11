#!/bin/bash

# Check if user is in the correct directory
if [ ! -f wp-config.php ]; then
    echo "Error: You are not in the correct directory."
    exit 1
fi

# Welcome message
echo "Welcome to WordPress Mega Tool"
echo "Domain name: $(wp option get home | cut -d '/' -f3)"

# Get database information from wp-config.php
DB_NAME=$(grep -o "define( *'DB_NAME', *'[^']*')" wp-config.php | cut -d"'" -f4)
DB_USER=$(grep -o "define( *'DB_USER', *'[^']*')" wp-config.php | cut -d"'" -f4)
DB_PASS=$(grep -o "define( *'DB_PASSWORD', *'[^']*')" wp-config.php | cut -d"'" -f4)

# List of options
OPTIONS=("Create staging site" "Migrate WordPress site" "Reset WordPress user Password" "Import .xml file into database" "Database tool")

# Prompt user to choose an option
echo "Please choose an option:"
select OPTION in "${OPTIONS[@]}"; do
    case $OPTION in
        "Create staging site")
            # Create staging site
            if [ -d "staging" ]; then
                read -p "A staging directory already exists. Please enter a different name: " STAGING_NAME
                mkdir "staging/$STAGING_NAME"
                STAGING_DIR="staging/$STAGING_NAME/$(date +%s | shasum | base64 | head -c 4)"
            else
                mkdir "staging"
                STAGING_DIR="staging/$(date +%s | shasum | base64 | head -c 4)"
            fi
            cp -r !("staging") "$STAGING_DIR"
            echo "Created staging site at $STAGING_DIR"
            read -p "Do you want to proceed with the database? " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                # Create database and user
                read -p "Enter database name: " DB_NAME_NEW
                uapi Mysql create_database name="$DB_NAME_NEW"
                echo "Database created: $DB_NAME_NEW"
                read -p "Enter database username: " DB_USER_NEW
                read -s -p "Enter database password: " DB_PASS_NEW
                echo
                uapi Mysql create_user name="$DB_USER_NEW" password="$DB_PASS_NEW"
                echo "Database user created: $DB_USER_NEW"
                uapi Mysql set_privileges_on_database database="$DB_NAME_NEW" user="$DB_USER_NEW" privileges="ALL PRIVILEGES"
                echo "Privileges set for $DB_USER_NEW on $DB_NAME_NEW"
                
                # Update wp-config.php with new database information
                sed -i "s/define('DB_NAME', '$DB_NAME')/define('DB_NAME', '$DB_NAME_NEW')/g" "$STAGING_DIR/wp-config.php"
                sed -i "s/define('DB_USER', '$DB_USER')/define('DB_USER', '$DB_USER_NEW')/g" "$STAGING_DIR/wp-config.php"
                sed -i "s/define('DB_PASSWORD', '$DB_PASS')/define('DB_PASSWORD', '$DB_PASS_NEW')/g" "$STAGING_DIR/wp-config.php"
                echo "Updated wp-config.php with new database information"
            fi
            break;;
        "Migrate WordPress site")
            echo "Migrate WordPress site
