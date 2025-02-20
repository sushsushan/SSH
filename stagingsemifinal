#!/bin/bash 

# Function to display errors
handle_error() {
    echo "❌ Error: $1"
    exit 1
}

# Confirm the directory
read -p "Are you in the correct WordPress directory? (y/n): " confirm
if [[ "$confirm" != "y" ]]; then
    read -p "Enter the correct path: " main_path
else
    main_path=$(pwd)
fi

# Fetch WordPress details
echo "🔍 Fetching WordPress details..."
wp_home=$(wp option get home --path="$main_path" 2>/dev/null) || handle_error "Failed to get Home URL."
wp_siteurl=$(wp option get siteurl --path="$main_path" 2>/dev/null) || handle_error "Failed to get Site URL."
db_name=$(grep "DB_NAME" "$main_path/wp-config.php" | cut -d "'" -f 4)
db_user=$(grep "DB_USER" "$main_path/wp-config.php" | cut -d "'" -f 4)
db_password=$(grep "DB_PASSWORD" "$main_path/wp-config.php" | cut -d "'" -f 4)
db_host=$(grep "DB_HOST" "$main_path/wp-config.php" | cut -d "'" -f 4)
table_prefix=$(awk -F"'" '/table_prefix/ {print $2}' "$main_path/wp-config.php")

echo "📌 Current WordPress Home URL: $wp_home"
echo "📌 Current WordPress Site URL: $wp_siteurl"
echo "📌 Database Info: DB_NAME=$db_name, DB_USER=$db_user"

# Ask user to create staging site
read -p "Would you like to create a staging site? (y/n): " choice
if [[ "$choice" != "y" ]]; then
    exit 0
fi

# Generate staging folder
staging_folder="$main_path/staging_$(shuf -i 10000-99999 -n 1)"
mkdir -p "$staging_folder" || handle_error "Failed to create staging directory."

echo "🚀 Creating Staging Site at $staging_folder ..."

# Copy files excluding staging folder
rsync -a --exclude='staging_*' "$main_path/" "$staging_folder/" || handle_error "Failed to copy files."

# Backup current database
backup_folder="$HOME/backup"
mkdir -p "$backup_folder"
backup_file="$backup_folder/$(date +%Y%m%d_%H%M%S)_backup.sql"
wp db export "$backup_file" --path="$main_path" --quiet || handle_error "Database export failed."

# Generate new database details
HOST_USER=$(whoami)
DB_NAME="staging_db_$(date +%s)"
DB_USER="${HOST_USER}_${DB_NAME}"
DB_PASS=$(openssl rand -base64 12)
FULL_DB_NAME="${HOST_USER}_${DB_NAME}"

# Create new database and user
uapi Mysql create_database name="$FULL_DB_NAME" >/dev/null 2>&1 || handle_error "Failed to create database."
uapi Mysql create_user name="$DB_USER" password="$DB_PASS" >/dev/null 2>&1 || handle_error "Failed to create database user."
uapi Mysql set_privileges_on_database database="$FULL_DB_NAME" user="$DB_USER" privileges="ALL PRIVILEGES" >/dev/null 2>&1 || handle_error "Failed to set database privileges."

# Import the database
mysql -u "$DB_USER" -p"$DB_PASS" -h "$db_host" "$FULL_DB_NAME" < "$backup_file" || handle_error "Database import failed."

# Update wp-config.php in the staging site
sed -i "s/define( *'DB_NAME'.*/define('DB_NAME', '$FULL_DB_NAME');/" "$staging_folder/wp-config.php"
sed -i "s/define( *'DB_USER'.*/define('DB_USER', '$DB_USER');/" "$staging_folder/wp-config.php"
sed -i "s/define( *'DB_PASSWORD'.*/define('DB_PASSWORD', '$DB_PASS');/" "$staging_folder/wp-config.php"

# Update URLs in the staging database
staging_url="${wp_home}/staging_$(basename "$staging_folder")"
mysql -u "$DB_USER" -p"$DB_PASS" -h "$db_host" "$FULL_DB_NAME" -e "
UPDATE ${table_prefix}options SET option_value = '$staging_url' WHERE option_name IN ('siteurl', 'home');
UPDATE ${table_prefix}posts SET post_content = REPLACE(post_content, '$wp_home', '$staging_url');
UPDATE ${table_prefix}posts SET guid = REPLACE(guid, '$wp_home', '$staging_url');
UPDATE ${table_prefix}postmeta SET meta_value = REPLACE(meta_value, '$wp_home', '$staging_url');
UPDATE ${table_prefix}usermeta SET meta_value = REPLACE(meta_value, '$wp_home', '$staging_url');
UPDATE ${table_prefix}comments SET comment_content = REPLACE(comment_content, '$wp_home', '$staging_url');
UPDATE ${table_prefix}comments SET comment_author_url = REPLACE(comment_author_url, '$wp_home', '$staging_url');
UPDATE ${table_prefix}links SET link_url = REPLACE(link_url, '$wp_home', '$staging_url');
UPDATE ${table_prefix}links SET link_image = REPLACE(link_image, '$wp_home', '$staging_url');
" || handle_error "Failed to update URLs."

# Fetch updated Site URL and Home URL
after_site_url=$(mysql -u "$DB_USER" -p"$DB_PASS" -h "$db_host" "$FULL_DB_NAME" -se "SELECT option_value FROM ${table_prefix}options WHERE option_name='siteurl';")
after_home_url=$(mysql -u "$DB_USER" -p"$DB_PASS" -h "$db_host" "$FULL_DB_NAME" -se "SELECT option_value FROM ${table_prefix}options WHERE option_name='home';")

# Set correct permissions
chown -R $(whoami):$(whoami) "$staging_folder"
find "$staging_folder" -type d -exec chmod 755 {} \;
find "$staging_folder" -type f -exec chmod 644 {} \;

# Completion message
echo "✅ Staging site created successfully!"
echo "🔄 Updated Site URL: $wp_home → $after_site_url"
echo "🔄 Updated Home URL: $wp_home → $after_home_url"
echo "📂 Staging Path: $staging_folder"
echo "🗂 Database: $FULL_DB_NAME"
echo "🔑 Database User: $DB_USER"
echo "🔑 Database Password: $DB_PASS"
echo "🎯 You can now access your staging site at: $staging_url"
