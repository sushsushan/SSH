#!/bin/bash

# Function to extract database credentials from wp-config.php
get_db_credentials() {
    WP_CONFIG="wp-config.php"
    DB_NAME=$(grep -oP "(?<=DB_NAME', ')[^']*" $WP_CONFIG)
    DB_USER=$(grep -oP "(?<=DB_USER', ')[^']*" $WP_CONFIG)
    DB_PASS=$(grep -oP "(?<=DB_PASSWORD', ')[^']*" $WP_CONFIG)
    DB_HOST=$(grep -oP "(?<=DB_HOST', ')[^']*" $WP_CONFIG)
}

# Prompt user for old and new domain
read -p "Enter OLD domain (e.g., olddomain.com or www.olddomain.com): " OLD_DOMAIN
read -p "Enter NEW domain (e.g., newdomain.com or www.newdomain.com): " NEW_DOMAIN

# Detect www preference
if [[ $OLD_DOMAIN == www.* ]]; then
    OLD_DOMAINS=("http://$OLD_DOMAIN" "https://$OLD_DOMAIN" "$OLD_DOMAIN")
else
    OLD_DOMAINS=("http://$OLD_DOMAIN" "https://$OLD_DOMAIN" "$OLD_DOMAIN")
fi

# Force all replacements to use HTTPS
NEW_DOMAIN_SECURE="https://$NEW_DOMAIN"

# Display detected values
echo -e "\nReplacing the following URLs:"
for URL in "${OLD_DOMAINS[@]}"; do
    echo " - $URL  →  $NEW_DOMAIN_SECURE"
done
echo -e "\n"

# Confirm backup
read -p "Do you have a full database backup? (yes/no): " CONFIRM_BACKUP
if [[ "$CONFIRM_BACKUP" != "yes" ]]; then
    echo "Please take a backup before proceeding."
    exit 1
fi

# Get database credentials
get_db_credentials

# Confirm action
echo "Database Name: $DB_NAME"
echo "Proceeding will update the database. Type 'confirm' to continue."
read -p "> " CONFIRM_ACTION
if [[ "$CONFIRM_ACTION" != "confirm" ]]; then
    echo "Operation aborted."
    exit 1
fi

# Create new MySQL user & grant privileges
DB_NEW_USER="$(whoami)_$(openssl rand -hex 4)"
DB_NEW_PASS=$(openssl rand -base64 12)
uapi Mysql create_user name="$DB_NEW_USER" password="$DB_NEW_PASS" >/dev/null 2>&1
uapi Mysql set_privileges_on_database database="$DB_NAME" user="$DB_NEW_USER" privileges="ALL PRIVILEGES" >/dev/null 2>&1

# Show before replacement
echo -e "\nChecking URLs before replacement..."
for URL in "${OLD_DOMAINS[@]}"; do
    COUNT=$(mysql -u "$DB_NEW_USER" -p"$DB_NEW_PASS" -D "$DB_NAME" -e "SELECT COUNT(*) FROM wp_posts WHERE post_content LIKE '%$URL%';" | tail -n 1)
    echo "Occurrences of $URL: $COUNT"
done

# Run MySQL queries to replace all URLs across critical tables
for URL in "${OLD_DOMAINS[@]}"; do
    mysql -u "$DB_NEW_USER" -p"$DB_NEW_PASS" -D "$DB_NAME" -e "
    UPDATE wp_options SET option_value = REPLACE(option_value, '$URL', '$NEW_DOMAIN_SECURE') WHERE option_name IN ('siteurl', 'home');
    UPDATE wp_posts SET post_content = REPLACE(post_content, '$URL', '$NEW_DOMAIN_SECURE');
    UPDATE wp_posts SET guid = REPLACE(guid, '$URL', '$NEW_DOMAIN_SECURE');
    UPDATE wp_postmeta SET meta_value = REPLACE(meta_value, '$URL', '$NEW_DOMAIN_SECURE');
    UPDATE wp_usermeta SET meta_value = REPLACE(meta_value, '$URL', '$NEW_DOMAIN_SECURE');
    UPDATE wp_comments SET comment_content = REPLACE(comment_content, '$URL', '$NEW_DOMAIN_SECURE');
    UPDATE wp_comments SET comment_author_url = REPLACE(comment_author_url, '$URL', '$NEW_DOMAIN_SECURE');
    UPDATE wp_links SET link_url = REPLACE(link_url, '$URL', '$NEW_DOMAIN_SECURE');
    UPDATE wp_links SET link_image = REPLACE(link_image, '$URL', '$NEW_DOMAIN_SECURE');
    "
done

# Run WP-CLI search-replace for serialized data
wp search-replace "${OLD_DOMAINS[1]}" "$NEW_DOMAIN_SECURE" --all-tables --precise --recurse-objects

# Show after replacement
echo -e "\nChecking URLs after replacement..."
for URL in "${OLD_DOMAINS[@]}"; do
    COUNT=$(mysql -u "$DB_NEW_USER" -p"$DB_NEW_PASS" -D "$DB_NAME" -e "SELECT COUNT(*) FROM wp_posts WHERE post_content LIKE '%$URL%';" | tail -n 1)
    echo "Occurrences of $URL: $COUNT"
done

# Optimize tables
mysql -u "$DB_NEW_USER" -p"$DB_NEW_PASS" -D "$DB_NAME" -e "OPTIMIZE TABLE $(mysql -u "$DB_NEW_USER" -p"$DB_NEW_PASS" -D "$DB_NAME" -Bse 'SHOW TABLES' | tr '\n' ',' | sed 's/,$//');"

# Clean up MySQL user
uapi Mysql delete_user name="$DB_NEW_USER" >/dev/null 2>&1

echo -e "\n✅ URL Migration Completed!"
