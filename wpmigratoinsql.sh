#!/bin/bash

# Step 1: Ask for WWW or non-WWW version
echo "Do you want your new domain with 'www' or without 'www'?"
read -p "Enter choice (www/non-www): " WWW_CHOICE

# Step 2: Ask for Old and New Domains
read -p "Enter OLD domain (without https://): " OLD_DOMAIN
read -p "Enter NEW domain (without https://): " NEW_DOMAIN

# Format URLs based on user choice
if [[ "$WWW_CHOICE" == "www" ]]; then
    OLD_URL="https://www.$OLD_DOMAIN"
    NEW_URL="https://www.$NEW_DOMAIN"
else
    OLD_URL="https://$OLD_DOMAIN"
    NEW_URL="https://$NEW_DOMAIN"
fi

# Step 3: Fetch and Select Database
echo "Fetching available databases..."
mysql -u root -p -e "SHOW DATABASES;"
read -p "Enter the database name: " DB_NAME

# Step 4: Create a Temporary MySQL User
DB_USER="temp_user_$(openssl rand -hex 2)"
DB_PASS="$(openssl rand -base64 12)"
mysql -u root -p -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
mysql -u root -p -e "FLUSH PRIVILEGES;"
echo "Temporary MySQL user created: $DB_USER"

# Step 5: Count occurrences before updating
echo "Checking occurrences of the old domain in the database..."
RESULTS_BEFORE=$(mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "
SELECT 
  (SELECT COUNT(*) FROM wp_posts WHERE post_content LIKE '%$OLD_URL%') +
  (SELECT COUNT(*) FROM wp_options WHERE option_value LIKE '%$OLD_URL%') +
  (SELECT COUNT(*) FROM wp_posts WHERE guid LIKE '%$OLD_URL%') +
  (SELECT COUNT(*) FROM wp_postmeta WHERE meta_value LIKE '%$OLD_URL%') +
  (SELECT COUNT(*) FROM wp_comments WHERE comment_content LIKE '%$OLD_URL%') AS total_results;
")
echo "Total occurrences found: $RESULTS_BEFORE"

# Step 6: Backup database before making changes
read -p "Would you like to take a database backup before updating? (yes/no): " BACKUP_CONFIRM
if [[ "$BACKUP_CONFIRM" == "yes" ]]; then
    BACKUP_FILE="wp_backup_$(date +%F_%H-%M-%S).sql"
    echo "Backing up database to $BACKUP_FILE..."
    mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE"
    echo "Backup completed: $BACKUP_FILE"
fi

# Step 7: Update all URLs in the database
echo "Updating database URLs from $OLD_URL to $NEW_URL..."
mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "
UPDATE wp_options SET option_value = REPLACE(option_value, '$OLD_URL', '$NEW_URL') WHERE option_name IN ('siteurl', 'home');
UPDATE wp_posts SET post_content = REPLACE(post_content, '$OLD_URL', '$NEW_URL');
UPDATE wp_posts SET guid = REPLACE(guid, '$OLD_URL', '$NEW_URL');
UPDATE wp_postmeta SET meta_value = REPLACE(meta_value, '$OLD_URL', '$NEW_URL');
UPDATE wp_comments SET comment_content = REPLACE(comment_content, '$OLD_URL', '$NEW_URL');
"

# Step 8: Count occurrences after updating
echo "Verifying update..."
RESULTS_AFTER=$(mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" -e "
SELECT 
  (SELECT COUNT(*) FROM wp_posts WHERE post_content LIKE '%$OLD_URL%') +
  (SELECT COUNT(*) FROM wp_options WHERE option_value LIKE '%$OLD_URL%') +
  (SELECT COUNT(*) FROM wp_posts WHERE guid LIKE '%$OLD_URL%') +
  (SELECT COUNT(*) FROM wp_postmeta WHERE meta_value LIKE '%$OLD_URL%') +
  (SELECT COUNT(*) FROM wp_comments WHERE comment_content LIKE '%$OLD_URL%') AS total_results;
")

echo "Results after update: $RESULTS_AFTER"

# Step 9: Remove Temporary MySQL User
mysql -u root -p -e "DROP USER '$DB_USER'@'localhost';"
mysql -u root -p -e "FLUSH PRIVILEGES;"
echo "✅ Temporary MySQL user removed."

echo "✅ WordPress database URLs updated successfully!"
