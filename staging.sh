#!/bin/bash

echo "=============================================="
echo "  Welcome to the Advanced Staging Creton Tool "
echo "=============================================="
echo ""
echo "Staging is important because it allows you to test updates, new plugins, and changes without affecting your live website."
echo "This tool will create a staging copy of your WordPress site for safe testing."
echo ""

# Step 1: Scan for WordPress installations
echo "Scanning for installed WordPress sites..."
WP_SITES=($(find $HOME -type f -name "wp-config.php" | sed 's|/wp-config.php||'))

if [[ ${#WP_SITES[@]} -eq 0 ]]; then
    echo "No WordPress installations found. Exiting."
    exit 1
fi

# Display found WordPress sites
echo "Found the following WordPress installations:"
for i in "${!WP_SITES[@]}"; do
    SITE_URL=$(grep -oP "(?<=WP_HOME', ').*?(?=')" "${WP_SITES[$i]}/wp-config.php" 2>/dev/null || echo "Unknown URL")
    echo "$((i+1)). ${WP_SITES[$i]} - $SITE_URL"
done

# Step 2: Ask user to select a WordPress site
read -p "Enter the number corresponding to your WordPress installation: " SELECTION
if ! [[ "$SELECTION" =~ ^[0-9]+$ ]] || (( SELECTION < 1 || SELECTION > ${#WP_SITES[@]} )); then
    echo "Invalid selection. Exiting."
    exit 1
fi

WP_PATH="${WP_SITES[$((SELECTION-1))]}"
echo "Selected WordPress Installation: $WP_PATH"

# Step 3: Extract Database Credentials from wp-config.php
DB_NAME=$(grep DB_NAME "$WP_PATH/wp-config.php" | cut -d "'" -f 4)
DB_USER=$(grep DB_USER "$WP_PATH/wp-config.php" | cut -d "'" -f 4)
DB_PASS=$(grep DB_PASSWORD "$WP_PATH/wp-config.php" | cut -d "'" -f 4)

echo "WordPress Site URL: $(grep -oP "(?<=WP_HOME', ').*?(?=')" "$WP_PATH/wp-config.php" 2>/dev/null || echo "Unknown")"
echo "Database Name: $DB_NAME"
echo "Database User: $DB_USER"

# Step 4: Ask user to continue
read -p "Do you want to continue with staging? (yes/no): " CONTINUE
if [[ "$CONTINUE" != "yes" ]]; then
    echo "Operation cancelled. Exiting."
    exit 0
fi

# Step 5: Create Staging Directory
STAGING_DIR="$WP_PATH/staging/$(shuf -i 1000-9999 -n 1)"
mkdir -p "$STAGING_DIR"

echo "Copying WordPress files to $STAGING_DIR..."
rsync -av --exclude "staging" "$WP_PATH/" "$STAGING_DIR/" --quiet
echo "Files copied successfully."

# Step 6: Backup Database
BACKUP_DIR="$HOME/backup"
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_$(date +%Y%m%d_%H%M%S).sql"

echo "Taking database backup..."
if command -v wp &> /dev/null && wp db export "$BACKUP_FILE" --path="$WP_PATH" --quiet; then
    echo "Database backup successful (WP-CLI)."
else
    echo "WP-CLI failed, using mysqldump..."
    mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE"
    echo "Database backup successful (mysqldump)."
fi

# Step 7: Create New Database and User
NEW_DB_NAME="staging_$(date +%s)"
NEW_DB_USER="user_$(shuf -i 1000-9999 -n 1)"
NEW_DB_PASS=$(openssl rand -base64 12)

echo "Creating new database and user..."
uapi Mysql create_database name="$NEW_DB_NAME" >/dev/null 2>&1
uapi Mysql create_user name="$NEW_DB_USER" password="$NEW_DB_PASS" >/dev/null 2>&1
uapi Mysql set_privileges_on_database database="$NEW_DB_NAME" user="$NEW_DB_USER" privileges="ALL PRIVILEGES" >/dev/null 2>&1
echo "Database setup completed."

# Step 8: Update wp-config.php in Staging
sed -i "s/define('DB_NAME',.*/define('DB_NAME', '$NEW_DB_NAME');/" "$STAGING_DIR/wp-config.php"
sed -i "s/define('DB_USER',.*/define('DB_USER', '$NEW_DB_USER');/" "$STAGING_DIR/wp-config.php"
sed -i "s/define('DB_PASSWORD',.*/define('DB_PASSWORD', '$NEW_DB_PASS');/" "$STAGING_DIR/wp-config.php"

echo "Updated wp-config.php for staging site."

# Step 9: Import Database to New Staging Database
echo "Importing database to the new staging site..."
mysql -u "$NEW_DB_USER" -p"$NEW_DB_PASS" "$NEW_DB_NAME" < "$BACKUP_FILE"
echo "Database imported successfully."

# Step 10: Display Staging Path
echo ""
echo "============================================="
echo "  WordPress Staging Site Created Successfully"
echo "============================================="
echo "Your staging site is located at: $STAGING_DIR"
echo "You can now test your site safely without affecting the live version."
echo ""
