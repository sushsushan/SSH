#!/bin/bash

# Confirm if user is in correct directory
read -p "Are you in the correct directory? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    read -p "Enter the correct path: " main_path
else
    main_path=$(pwd)
fi

# Display total size and WordPress info
echo "Calculating directory size..."
total_size=$(du -sh "$main_path" | cut -f1)
wp_info=$(wp option get home --path="$main_path" 2>/dev/null)

echo "Total Size: $total_size"
echo "WordPress URL: $wp_info"

grep -E 'DB_NAME|DB_USER|DB_PASSWORD' "$main_path/wp-config.php"

# Ask user to create staging site
read -p "Would you like to create a staging site? (y/n): " choice
if [[ "$choice" != "y" ]]; then
    exit 0
fi

# Create staging folder with random number
staging_folder="$main_path/staging/$(shuf -i 10000-99999 -n 1)"
mkdir -p "$staging_folder"

echo "Creating staging site..."

# Copy files excluding staging folder
rsync -av --exclude='staging' "$main_path/" "$staging_folder/" --quiet

# Backup current database
backup_file="$HOME/backup/$(date +%Y%m%d_%H%M%S)_backup.sql"
wp db export "$backup_file" --path="$main_path" --quiet

# Create new database and user
HOST_USER=$(whoami)
DB_NAME="db_$(date +%s)"
DB_USER="${HOST_USER}_${DB_NAME}"
DB_PASS=$(openssl rand -base64 12)
FULL_DB_NAME="${HOST_USER}_${DB_NAME}"

uapi Mysql create_database name="$FULL_DB_NAME" >/dev/null 2>&1
uapi Mysql create_user name="$DB_USER" password="$DB_PASS" >/dev/null 2>&1
uapi Mysql set_privileges_on_database database="$FULL_DB_NAME" user="$DB_USER" privileges="ALL PRIVILEGES" >/dev/null 2>&1

# Import backup to new database
wp db import "$backup_file" --path="$staging_folder" --quiet

# Update wp-config.php in staging site
sed -i "s/define('DB_NAME'.*/define('DB_NAME', '$FULL_DB_NAME');/" "$staging_folder/wp-config.php"
sed -i "s/define('DB_USER'.*/define('DB_USER', '$DB_USER');/" "$staging_folder/wp-config.php"
sed -i "s/define('DB_PASSWORD'.*/define('DB_PASSWORD', '$DB_PASS');/" "$staging_folder/wp-config.php"

# Completion message
echo "Staging site created successfully."
