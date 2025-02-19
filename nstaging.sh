#!/bin/bash
# Fully Responsive WordPress Staging Site Creation Tool
# Minimal output: only essential messages are displayed

# Confirm if user is in the correct WordPress directory
read -p "Are you in the correct WordPress directory? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    read -p "Enter the correct WordPress directory path: " main_path
    if [[ ! -d "$main_path" ]]; then
        echo "Invalid directory! Exiting..."
        exit 1
    fi
else
    main_path=$(pwd)
fi

# Minimal log message to the user
echo "Creating staging site... please wait."

# Ensure backup directory exists
mkdir -p "$HOME/backup" >/dev/null 2>&1

# Create a staging folder with a random 5-digit number inside the staging directory
staging_folder="$main_path/staging/$(shuf -i 10000-99999 -n 1)"
mkdir -p "$staging_folder" >/dev/null 2>&1

# Copy all files and folders from main_path into staging folder, excluding any 'staging' folder
rsync -a --exclude='staging' "$main_path/" "$staging_folder/" >/dev/null 2>&1

# Backup the current database using WP-CLI (quiet mode)
backup_file="$HOME/backup/$(date +%Y%m%d_%H%M%S)_backup.sql"
wp db export "$backup_file" --path="$main_path" --quiet >/dev/null 2>&1

# Generate new database credentials (system-generated)
HOST_USER=$(whoami)
DB_NAME="db_$(date +%s)"
DB_USER="${HOST_USER}_${DB_NAME}"
DB_PASS=$(openssl rand -base64 12)
FULL_DB_NAME="${HOST_USER}_${DB_NAME}"

# Create new database and user; grant privileges via uapi (output suppressed)
uapi Mysql create_database name="$FULL_DB_NAME" >/dev/null 2>&1
uapi Mysql create_user name="$DB_USER" password="$DB_PASS" >/dev/null 2>&1
uapi Mysql set_privileges_on_database database="$FULL_DB_NAME" user="$DB_USER" privileges="ALL PRIVILEGES" >/dev/null 2>&1

# Import the backup into the new database for the staging site using WP-CLI (quiet mode)
wp db import "$backup_file" --path="$staging_folder" --quiet >/dev/null 2>&1

# Update wp-config.php in the staging site with the new database credentials
config_file="$staging_folder/wp-config.php"
if [ -f "$config_file" ]; then
    sed -i "s/\(define('DB_NAME', *'\)[^']*\('.*\)/\1$FULL_DB_NAME\2/" "$config_file" >/dev/null 2>&1
    sed -i "s/\(define('DB_USER', *'\)[^']*\('.*\)/\1$DB_USER\2/" "$config_file" >/dev/null 2>&1
    sed -i "s/\(define('DB_PASSWORD', *'\)[^']*\('.*\)/\1$DB_PASS\2/" "$config_file" >/dev/null 2>&1
fi

# Completion message (minimal output)
echo "Staging site created successfully."
