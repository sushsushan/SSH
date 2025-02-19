#!/bin/bash

# Confirm if user is in correct directory
echo "Current Path: $(pwd)"
read -p "Are you in the correct directory? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    read -p "Enter the correct path: " main_path
else
    main_path=$(pwd)
fi

echo "Checking WordPress details..."
# Fetch WordPress home URL and database info
wp_home=$(wp option get home --path="$main_path" 2>/dev/null)
wp_siteurl=$(wp option get siteurl --path="$main_path" 2>/dev/null)
db_name=$(grep "DB_NAME" "$main_path/wp-config.php" | cut -d "'" -f 4)
db_user=$(grep "DB_USER" "$main_path/wp-config.php" | cut -d "'" -f 4)
db_password=$(grep "DB_PASSWORD" "$main_path/wp-config.php" | cut -d "'" -f 4)

echo "----------------------------------"
echo "Directory Size: $(du -sh "$main_path" | cut -f1)"
echo "WordPress Home URL: $wp_home"
echo "WordPress Site URL: $wp_siteurl"
echo "Database Information:" 
echo "   DB_NAME: $db_name"
echo "   DB_USER: $db_user"
echo "----------------------------------"

# Ask user to create staging site
read -p "Would you like to create a staging site? (y/n): " choice
if [[ "$choice" != "y" ]]; then
    exit 0
fi

echo "Initializing staging setup..."
# Create staging folder with random number
staging_folder="$main_path/staging/$(shuf -i 10000-99999 -n 1)"
mkdir -p "$staging_folder"

echo "Backing up current database..."
# Backup current database
backup_folder="$HOME/backup"
mkdir -p "$backup_folder"
backup_file="$backup_folder/$(date +%Y%m%d_%H%M%S)_backup.sql"
if wp db export "$backup_file" --path="$main_path" --quiet; then
    echo "Database backup completed."
else
    echo "wp-cli export failed, using MySQL dump."
    mysqldump -u "$db_user" -p"$db_password" "$db_name" > "$backup_file"
fi

echo "Copying files to staging environment..."
# Copy files excluding staging folder
rsync -a --exclude='staging' "$main_path/" "$staging_folder/"

echo "Creating new database and user..."
# Create new database and user
HOST_USER=$(whoami)
DB_NAME="db_$(date +%s)"
DB_USER="${HOST_USER}_${DB_NAME}"
DB_PASS=$(openssl rand -base64 12)
FULL_DB_NAME="${HOST_USER}_${DB_NAME}"

uapi Mysql create_database name="$FULL_DB_NAME" >/dev/null 2>&1
uapi Mysql create_user name="$DB_USER" password="$DB_PASS" >/dev/null 2>&1
uapi Mysql set_privileges_on_database database="$FULL_DB_NAME" user="$DB_USER" privileges="ALL PRIVILEGES" >/dev/null 2>&1

echo "Updating database details in wp-config.php..."
# Update wp-config.php in staging site
sed -i "s/define( *'DB_NAME'.*/define('DB_NAME', '$FULL_DB_NAME');/" "$staging_folder/wp-config.php"
sed -i "s/define( *'DB_USER'.*/define('DB_USER', '$DB_USER');/" "$staging_folder/wp-config.php"
sed -i "s/define( *'DB_PASSWORD'.*/define('DB_PASSWORD', '$DB_PASS');/" "$staging_folder/wp-config.php"

echo "Importing database backup to new database..."
# Import backup to new database
if wp db import "$backup_file" --path="$staging_folder" --quiet --allow-root; then
    echo "Database import completed using wp-cli."
else
    echo "wp-cli import failed, using MySQL import."
    mysql -u "$DB_USER" -p"$DB_PASS" "$FULL_DB_NAME" < "$backup_file"
fi

echo "----------------------------------"
echo "Staging site created successfully!"
echo "Path: $staging_folder"
echo "Database: $FULL_DB_NAME"
echo "----------------------------------"
