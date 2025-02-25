#!/bin/bash

# Function to generate a 4-digit random number
generate_random_number() {
    echo $((RANDOM % 9000 + 1000))
}

# Welcome message
echo "=============================================="
echo "  Welcome to the Advanced Staging Creton Tool "
echo "=============================================="
echo ""

# Detect and List WordPress Installations
echo "Scanning for installed WordPress sites..."
WP_DIRS=($(find ~ -type d -name "wp-admin" -exec dirname {} \; 2>/dev/null))

if [[ ${#WP_DIRS[@]} -eq 0 ]]; then
    echo "No WordPress installations found in your home directory."
    exit 1
fi

echo "Found the following WordPress installations:"
for i in "${!WP_DIRS[@]}"; do
    echo "$((i+1)). ${WP_DIRS[$i]}"
done

# Select WordPress Directory
read -p "Enter the number corresponding to your WordPress installation: " selection
if ! [[ "$selection" =~ ^[0-9]+$ ]] || (( selection < 1 || selection > ${#WP_DIRS[@]} )); then
    echo "Invalid selection. Exiting."
    exit 1
fi

WP_PATH="${WP_DIRS[$((selection-1))]}"
echo "You selected: $WP_PATH"

# Confirm WordPress Installation
if [[ ! -f "$WP_PATH/wp-config.php" ]]; then
    echo "Error: No WordPress installation detected in $WP_PATH"
    exit 1
fi

# Extract Database Credentials
DB_NAME=$(grep -oP "(?<=DB_NAME', ').*?(?=')" "$WP_PATH/wp-config.php")
DB_USER=$(grep -oP "(?<=DB_USER', ').*?(?=')" "$WP_PATH/wp-config.php")
DB_PASS=$(grep -oP "(?<=DB_PASSWORD', ').*?(?=')" "$WP_PATH/wp-config.php")
SITE_URL=$(wp option get siteurl --path="$WP_PATH" 2>/dev/null)

echo "======================================"
echo "  WordPress Installation Details"
echo "======================================"
echo "Site URL      : $SITE_URL"
echo "Database Name : $DB_NAME"
echo "DB Username   : $DB_USER"
echo "======================================"

# Create Backup Folder
BACKUP_DIR=~/backup
mkdir -p "$BACKUP_DIR"
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_$(date +"%Y%m%d_%H%M%S").sql"

echo "Taking database backup..."
if wp db export "$BACKUP_FILE" --path="$WP_PATH" 2>/dev/null; then
    echo "Database backup successful: $BACKUP_FILE"
else
    echo "WP-CLI failed, using mysqldump..."
    mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE"
    if [[ $? -ne 0 ]]; then
        echo "Database backup failed!"
        exit 1
    fi
    echo "Database backup completed: $BACKUP_FILE"
fi

# Create Staging Directory
STAGING_DIR="$WP_PATH/staging"
mkdir -p "$STAGING_DIR"
RANDOM_ID=$(generate_random_number)
STAGING_SUBDIR="$STAGING_DIR/$RANDOM_ID"
mkdir "$STAGING_SUBDIR"

# Copy Files to Staging Directory
echo "Copying files to the staging site..."
rsync -av --exclude='staging' "$WP_PATH/" "$STAGING_SUBDIR/" --quiet

# Create New Database for Staging
HOST_USER=$(whoami)
DB_NAME_NEW="staging_${RANDOM_ID}"
DB_USER_NEW="${HOST_USER}_${DB_NAME_NEW}"
DB_PASS_NEW=$(openssl rand -base64 12)

echo "Creating new database and user..."
uapi Mysql create_database name="$DB_NAME_NEW" >/dev/null 2>&1
uapi Mysql create_user name="$DB_USER_NEW" password="$DB_PASS_NEW" >/dev/null 2>&1
uapi Mysql set_privileges_on_database database="$DB_NAME_NEW" user="$DB_USER_NEW" privileges="ALL PRIVILEGES" >/dev/null 2>&1

echo "======================================"
echo "  New Database Created for Staging"
echo "======================================"
echo "Database Name : $DB_NAME_NEW"
echo "DB Username   : $DB_USER_NEW"
echo "DB Password   : $DB_PASS_NEW"

# Update wp-config.php in Staging
echo "Updating wp-config.php for the staging site..."
sed -i "s/define('DB_NAME',.*/define('DB_NAME', '$DB_NAME_NEW');/" "$STAGING_SUBDIR/wp-config.php"
sed -i "s/define('DB_USER',.*/define('DB_USER', '$DB_USER_NEW');/" "$STAGING_SUBDIR/wp-config.php"
sed -i "s/define('DB_PASSWORD',.*/define('DB_PASSWORD', '$DB_PASS_NEW');/" "$STAGING_SUBDIR/wp-config.php"

# Import Backup Database to New Staging DB
echo "Importing backup database to the new staging database..."
mysql -u "$DB_USER_NEW" -p"$DB_PASS_NEW" "$DB_NAME_NEW" < "$BACKUP_FILE"

if [[ $? -eq 0 ]]; then
    echo "Database imported successfully!"
else
    echo "Failed to import the database!"
    exit 1
fi

echo "======================================"
echo "  Staging Site Created Successfully!  "
echo "======================================"
echo "Path: $STAGING_SUBDIR"
echo "Database: $DB_NAME_NEW"
echo "Username: $DB_USER_NEW"
echo "Password: $DB_PASS_NEW"
echo "Now you can test your changes safely."
