#!/bin/bash

# Function to extract database credentials from wp-config.php
get_db_credentials() {
    WP_CONFIG="wp-config.php"
    
    DB_NAME=$(awk -F"'" '/DB_NAME/ {print $4}' $WP_CONFIG)
    DB_USER=$(awk -F"'" '/DB_USER/ {print $4}' $WP_CONFIG)
    DB_PASS=$(awk -F"'" '/DB_PASSWORD/ {print $4}' $WP_CONFIG)
    DB_HOST=$(awk -F"'" '/DB_HOST/ {print $4}' $WP_CONFIG)

    if [[ -z "$DB_NAME" || -z "$DB_USER" || -z "$DB_PASS" || -z "$DB_HOST" ]]; then
        echo "❌ Error: Could not extract database credentials from wp-config.php"
        exit 1
    fi
}

# Prompt user for old and new domain
read -p "Enter OLD domain (e.g., olddomain.com or www.olddomain.com): " OLD_DOMAIN
read -p "Enter NEW domain (e.g., newdomain.com or www.newdomain.com): " NEW_DOMAIN

# Ensure domains are formatted correctly
OLD_DOMAINS=("http://$OLD_DOMAIN" "https://$OLD_DOMAIN" "$OLD_DOMAIN")
NEW_DOMAIN_SECURE="https://$NEW_DOMAIN"

# Display detected values
echo -e "\nThe following URLs will be replaced:"
for URL in "${OLD_DOMAINS[@]}"; do
    echo " - $URL  →  $NEW_DOMAIN_SECURE"
done

# Confirm backup
while true; do
    read -p "Do you have a full database backup? (y/n): " CONFIRM_BACKUP
    case "$CONFIRM_BACKUP" in
        [yY]) break ;;
        [nN]) echo "⚠️ Please take a full database backup before proceeding."; exit 1 ;;
        *) echo "❌ Invalid input! Please enter 'y' for Yes or 'n' for No." ;;
    esac
done

# Get database credentials
get_db_credentials

# Confirm action with Yes/No
while true; do
    read -p "Proceed with URL update? (y/n): " CONFIRM_ACTION
    case "$CONFIRM_ACTION" in
        [yY]) break ;;
        [nN]) echo "Operation aborted."; exit 1 ;;
        *) echo "❌ Invalid input! Please enter 'y' for Yes or 'n' for No." ;;
    esac
done

# Check MySQL connection
if ! mysql -u "$DB_USER" -p"$DB_PASS" -h "$DB_HOST" -e "USE $DB_NAME;" 2>/dev/null; then
    echo "❌ Error: Unable to connect to MySQL database!"
    exit 1
fi

# Run MySQL queries to replace URLs
echo -e "\n🔄 Updating URLs in the database...\n"
for URL in "${OLD_DOMAINS[@]}"; do
    mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -h "$DB_HOST" -e "
    UPDATE wp_options SET option_value = REPLACE(option_value, '$URL', '$NEW_DOMAIN_SECURE') WHERE option_name IN ('siteurl', 'home');
    UPDATE wp_posts SET post_content = REPLACE(post_content, '$URL', '$NEW_DOMAIN_SECURE');
    UPDATE wp_posts SET guid = REPLACE(guid, '$URL', '$NEW_DOMAIN_SECURE');
    UPDATE wp_postmeta SET meta_value = REPLACE(meta_value, '$URL', '$NEW_DOMAIN_SECURE');
    UPDATE wp_usermeta SET meta_value = REPLACE(meta_value, '$URL', '$NEW_DOMAIN_SECURE');
    UPDATE wp_comments SET comment_content = REPLACE(comment_content, '$URL', '$NEW_DOMAIN_SECURE');
    UPDATE wp_comments SET comment_author_url = REPLACE(comment_author_url, '$URL', '$NEW_DOMAIN_SECURE');
    UPDATE wp_links SET link_url = REPLACE(link_url, '$URL', '$NEW_DOMAIN_SECURE');
    UPDATE wp_links SET link_image = REPLACE(link_image, '$URL', '$NEW_DOMAIN_SECURE');
    " 2>/dev/null
done

# Run WP-CLI search-replace if available
if command -v wp &> /dev/null; then
    echo -e "\n🔄 Running WP-CLI search-replace..."
    WP_CLI_OUTPUT=$(wp search-replace "${OLD_DOMAINS[1]}" "$NEW_DOMAIN_SECURE" --all-tables --precise --recurse-objects --allow-root --report-changed-only)
    if [[ -n "$WP_CLI_OUTPUT" ]]; then
        echo "$WP_CLI_OUTPUT"
    else
        echo "No changes were made via WP-CLI."
    fi
else
    echo "⚠️ WP-CLI not found. Skipping WP-CLI search-replace."
fi

echo -e "\n✅ URL Update Completed Successfully!"
