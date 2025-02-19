#!/bin/bash

# Function to extract values from wp-config.php
get_wp_config_value() {
    local key=$1
    grep -oP "(?<=define\('$key', ')[^']+" wp-config.php
}

# Step 1: Confirm the WordPress directory
while true; do
    echo -e "\nCurrent Directory: \033[1;32m$(pwd)\033[0m"
    read -p "Is this your WordPress installation? (y/n): " confirm
    if [[ "$confirm" == "y" ]]; then
        WP_DIR=$(pwd)
        break
    else
        read -p "Enter the full path of your WordPress directory: " WP_DIR
        if [[ -d "$WP_DIR" && -f "$WP_DIR/wp-config.php" ]]; then
            cd "$WP_DIR"
            break
        else
            echo -e "\033[1;31mInvalid WordPress directory. Try again.\033[0m"
        fi
    fi
done

# Step 2: Display total size of WordPress directory
echo -e "\n\033[1;34mTotal Size of WordPress Directory:\033[0m \033[1;33m$(du -sh "$WP_DIR" | cut -f1)\033[0m"

# Step 3: Get WordPress database details
DB_NAME=$(get_wp_config_value "DB_NAME")
DB_USER=$(get_wp_config_value "DB_USER")
DB_PASS=$(get_wp_config_value "DB_PASSWORD")
SITE_URL=$(wp option get siteurl --path="$WP_DIR" 2>/dev/null)

echo -e "\n\033[1;36mWordPress Configuration:\033[0m"
echo -e "  \033[1;33mSite URL:\033[0m $SITE_URL"
echo -e "  \033[1;33mDatabase Name:\033[0m $DB_NAME"
echo -e "  \033[1;33mDatabase User:\033[0m $DB_USER"
echo -e "  \033[1;33mDatabase Password:\033[0m [HIDDEN]"

# Step 4: Ask user to create a staging site
read -p "Would you like to create a staging site? (y/n): " create_staging
if [[ "$create_staging" != "y" ]]; then
    echo "Exiting..."
    exit 0
fi

# Step 5: Create the staging directory
STAGING_DIR="$WP_DIR/staging_$(date +%s)"
mkdir -p "$STAGING_DIR"
echo -e "\nCreating staging directory: \033[1;32m$STAGING_DIR\033[0m"

# Step 6: Copy all files to the staging directory
echo -e "\nCopying files..."
cp -r "$WP_DIR/"* "$STAGING_DIR/"
echo -e "\033[1;32mFile copy completed!\033[0m"

# Step 7: Backup the current database
BACKUP_FILE=~/backup/"$DB_NAME"_$(date +"%Y%m%d_%H%M%S").sql
mkdir -p ~/backup
echo -e "\nStarting database backup..."
mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE" 2>/dev/null

if [[ $? -eq 0 ]]; then
    echo -e "\033[1;32mBackup completed successfully:\033[0m \033[1;36m$BACKUP_FILE\033[0m"
else
    echo -e "\033[1;31mBackup failed!\033[0m"
    exit 1
fi

# Step 8: Create a new database for staging
NEW_DB_NAME="staging_${DB_NAME}"
NEW_DB_USER="staging_${DB_USER}"
NEW_DB_PASS=$(openssl rand -base64 12)

echo -e "\nCreating new database for staging..."
uapi Mysql create_database name="$NEW_DB_NAME" >/dev/null 2>&1
uapi Mysql create_user name="$NEW_DB_USER" password="$NEW_DB_PASS" >/dev/null 2>&1
uapi Mysql set_privileges_on_database database="$NEW_DB_NAME" user="$NEW_DB_USER" privileges="ALL PRIVILEGES" >/dev/null 2>&1

echo -e "\033[1;32mNew Database Created:\033[0m"
echo -e "  \033[1;33mDatabase:\033[0m $NEW_DB_NAME"
echo -e "  \033[1;33mUser:\033[0m $NEW_DB_USER"
echo -e "  \033[1;33mPassword:\033[0m $NEW_DB_PASS"

# Step 9: Import the backup into the new database
echo -e "\nImporting backup into the new database..."
mysql -u "$NEW_DB_USER" -p"$NEW_DB_PASS" "$NEW_DB_NAME" < "$BACKUP_FILE" 2>/dev/null

if [[ $? -eq 0 ]]; then
    echo -e "\033[1;32mDatabase imported successfully!\033[0m"
else
    echo -e "\033[1;31mDatabase import failed!\033[0m"
    exit 1
fi

# Step 10: Update wp-config.php in the staging environment
echo -e "\nUpdating wp-config.php in the staging site..."
sed -i "s/define('DB_NAME', '$DB_NAME')/define('DB_NAME', '$NEW_DB_NAME')/" "$STAGING_DIR/wp-config.php"
sed -i "s/define('DB_USER', '$DB_USER')/define('DB_USER', '$NEW_DB_USER')/" "$STAGING_DIR/wp-config.php"
sed -i "s/define('DB_PASSWORD', '$DB_PASS')/define('DB_PASSWORD', '$NEW_DB_PASS')/" "$STAGING_DIR/wp-config.php"

echo -e "\033[1;32mStaging site is ready!\033[0m"
echo -e "  \033[1;36mPath:\033[0m $STAGING_DIR"
echo -e "  \033[1;36mDatabase:\033[0m $NEW_DB_NAME"
echo -e "  \033[1;36mDatabase User:\033[0m $NEW_DB_USER"
