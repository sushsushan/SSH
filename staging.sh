#!/bin/bash

# Confirm if user is in correct directory
read -p "Are you in the correct directory? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    read -p "Enter the correct path: " main_path
else
    main_path=$(pwd)
fi

# Fetch WordPress home URL and database info
echo "Fetching WordPress details..."
wp_home=$(wp option get home --path="$main_path" 2>/dev/null)
wp_siteurl=$(wp option get siteurl --path="$main_path" 2>/dev/null)
db_name=$(grep "DB_NAME" "$main_path/wp-config.php" | cut -d "'" -f 4)
db_user=$(grep "DB_USER" "$main_path/wp-config.php" | cut -d "'" -f 4)
db_password=$(grep "DB_PASSWORD" "$main_path/wp-config.php" | cut -d "'" -f 4)

echo "Total Size: $(du -sh "$main_path" | cut -f1)"
echo "WordPress Home URL: $wp_home"
echo "WordPress Site URL: $wp_siteurl"
echo "Database Info: DB_NAME=$db_name, DB_USER=$db_user"

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
rsync -a --exclude='staging' "$main_path/" "$staging_folder/"

# Backup current database
backup_folder="$HOME/backup"
mkdir -p "$backup_folder"
backup_file="$backup_folder/$(date +%Y%m%d_%H%M%S)_backup.sql"
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
mysql -u "$DB_USER" -p"$DB_PASS" "$FULL_DB_NAME" < "$backup_file"

# Update wp-config.php in staging site
sed -i "s/define( *'DB_NAME'.*/define('DB_NAME', '$FULL_DB_NAME');/" "$staging_folder/wp-config.php"
sed -i "s/define( *'DB_USER'.*/define('DB_USER', '$DB_USER');/" "$staging_folder/wp-config.php"
sed -i "s/define( *'DB_PASSWORD'.*/define('DB_PASSWORD', '$DB_PASS');/" "$staging_folder/wp-config.php"

# Completion message
echo "Staging site created successfully."
