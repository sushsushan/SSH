#!/bin/bash

# Step 1: Ask for WWW or non-WWW
echo "Do you want your new domain with 'www' or without 'www'?"
read -p "Enter choice (www/non-www): " WWW_CHOICE

# Step 2: Ask for the domain names
read -p "Enter OLD domain (without https://): " OLD_DOMAIN
read -p "Enter NEW domain (without https://): " NEW_DOMAIN

# Format domains based on choice
if [[ "$WWW_CHOICE" == "www" ]]; then
    OLD_URL="https://www.$OLD_DOMAIN"
    NEW_URL="https://www.$NEW_DOMAIN"
else
    OLD_URL="https://$OLD_DOMAIN"
    NEW_URL="https://$NEW_DOMAIN"
fi

# Step 3: Fetch available databases
echo "Fetching available databases..."
uapi Mysql list_databases | grep -oP '(?<=database:\s).+'
read -p "Enter the database name: " DB_NAME

# Step 4: Generate temporary MySQL credentials
DB_USER="$(whoami)_$(openssl rand -hex 4)"
DB_PASS=$(openssl rand -base64 12)
uapi Mysql create_user name="$DB_USER" password="$DB_PASS" >/dev/null 2>&1
uapi Mysql set_privileges_on_database database="$DB_NAME" user="$DB_USER" privileges="ALL PRIVILEGES" >/dev/null 2>&1

# Step 5: Count occurrences before updating
echo "Checking occurrences of the old domain in the database..."
RESULTS_BEFORE=$(mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "
SELECT COUNT(*) FROM wp_posts WHERE post_content LIKE '%$OLD_URL%'
UNION
SELECT COUNT(*) FROM wp_options WHERE option_value LIKE '%$OLD_URL%'
UNION
SELECT COUNT(*) FROM wp_posts WHERE guid LIKE '%$OLD_URL%'
UNION
SELECT COUNT(*) FROM wp_postmeta WHERE meta_value LIKE '%$OLD_URL%'
UNION
SELECT COUNT(*) FROM wp_comments WHERE comment_content LIKE '%$OLD_URL%';
")

echo "Total occurrences found:"
echo "$RESULTS_BEFORE"

# Step 6: Ask for a database backup
read -p "Would you like to take a database backup before updating? (yes/no): " BACKUP_CONFIRM
if [[ "$BACKUP_CONFIRM" == "yes" ]]; then
    BACKUP_FILE="wp_backup_$(date +%F_%H-%M-%S).sql"
    echo "Backing up database to $BACKUP_FILE..."
    mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE"
    echo "Backup completed: $BACKUP_FILE"
fi

# Step 7: Update all occurrences in the database
echo "Updating database URLs from $OLD_URL to $NEW_URL..."
mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "
UPDATE wp_options SET option_value = REPLACE(option_value, '$OLD_URL', '$NEW_URL') WHERE option_name IN ('siteurl', 'home');
UPDATE wp_posts SET post_content = REPLACE(post_content, '$OLD_URL', '$NEW_URL');
UPDATE wp_posts SET guid = REPLACE(guid, '$OLD_URL', '$NEW_URL');
UPDATE wp_postmeta SET meta_value = REPLACE(meta_value, '$OLD_URL', '$NEW_URL');
UPDATE wp_comments SET comment_content = REPLACE(comment_content, '$OLD_URL', '$NEW_URL');
"

# Step 8: Count occurrences after updating
echo "Verifying update..."
RESULTS_AFTER=$(mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "
SELECT COUNT(*) FROM wp_posts WHERE post_content LIKE '%$OLD_URL%'
UNION
SELECT COUNT(*) FROM wp_options WHERE option_value LIKE '%$OLD_URL%'
UNION
SELECT COUNT(*) FROM wp_posts WHERE guid LIKE '%$OLD_URL%'
UNION
SELECT COUNT(*) FROM wp_postmeta WHERE meta_value LIKE '%$OLD_URL%'
UNION
SELECT COUNT(*) FROM wp_comments WHERE comment_content LIKE '%$OLD_URL%';
")

echo "Results after update:"
echo "$RESULTS_AFTER"

# Step 9: Remove temporary user
uapi Mysql delete_user name="$DB_USER" >/dev/null 2>&1

echo "✅ WordPress database URLs updated successfully!"
