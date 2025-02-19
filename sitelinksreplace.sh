#!/bin/bash

# Function to extract database credentials & table prefix from wp-config.php
get_wp_config_details() {
    WP_CONFIG="wp-config.php"
    
    DB_NAME=$(awk -F"'" '/DB_NAME/ {print $4}' $WP_CONFIG)
    DB_USER=$(awk -F"'" '/DB_USER/ {print $4}' $WP_CONFIG)
    DB_PASS=$(awk -F"'" '/DB_PASSWORD/ {print $4}' $WP_CONFIG)
    DB_HOST=$(awk -F"'" '/DB_HOST/ {print $4}' $WP_CONFIG)
    TABLE_PREFIX=$(awk -F"'" '/table_prefix/ {print $2}' $WP_CONFIG)

    if [[ -z "$DB_NAME" || -z "$DB_USER" || -z "$DB_PASS" || -z "$DB_HOST" || -z "$TABLE_PREFIX" ]]; then
        echo "❌ Error: Could not extract database credentials or table prefix from wp-config.php"
        exit 1
    fi
}

# Function to clean and standardize URLs
sanitize_url() {
    local URL=$1
    URL=$(echo "$URL" | sed -E 's|https?://||g')  # Remove http/https
    URL=$(echo "$URL" | sed -E 's|www\.||g')      # Remove www.
    echo "$URL"
}

# Prompt user for old and new domain
read -p "Enter OLD domain (e.g., olddomain.com or www.olddomain.com): " OLD_DOMAIN
read -p "Enter NEW domain (e.g., newdomain.com or www.newdomain.com): " NEW_DOMAIN

# Standardize the domains
OLD_DOMAIN_CLEAN=$(sanitize_url "$OLD_DOMAIN")
NEW_DOMAIN_CLEAN=$(sanitize_url "$NEW_DOMAIN")

# Construct both www and non-www versions
OLD_DOMAINS=("http://$OLD_DOMAIN_CLEAN" "https://$OLD_DOMAIN_CLEAN" "http://www.$OLD_DOMAIN_CLEAN" "https://www.$OLD_DOMAIN_CLEAN")
NEW_DOMAIN_SECURE="https://$NEW_DOMAIN_CLEAN"

# Confirm URL transformation
echo -e "\nThe following URLs will be updated:"
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

# Get database credentials & table prefix
get_wp_config_details

# Fetch current Site URL and Home URL before making changes
BEFORE_SITE_URL=$(mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -h "$DB_HOST" -se "SELECT option_value FROM ${TABLE_PREFIX}options WHERE option_name='siteurl';")
BEFORE_HOME_URL=$(mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -h "$DB_HOST" -se "SELECT option_value FROM ${TABLE_PREFIX}options WHERE option_name='home';")

echo -e "\n🔍 Current Site URL: $BEFORE_SITE_URL"
echo -e "🔍 Current Home URL: $BEFORE_HOME_URL"

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

# Run MySQL queries using the detected table prefix
echo -e "\n🔄 Updating URLs in the database...\n"
for URL in "${OLD_DOMAINS[@]}"; do
    mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -h "$DB_HOST" -e "
    UPDATE ${TABLE_PREFIX}options SET option_value = REPLACE(option_value, '$URL', '$NEW_DOMAIN_SECURE') WHERE option_name IN ('siteurl', 'home');
    UPDATE ${TABLE_PREFIX}posts SET post_content = REPLACE(post_content, '$URL', '$NEW_DOMAIN_SECURE');
    UPDATE ${TABLE_PREFIX}posts SET guid = REPLACE(guid, '$URL', '$NEW_DOMAIN_SECURE');
    UPDATE ${TABLE_PREFIX}postmeta SET meta_value = REPLACE(meta_value, '$URL', '$NEW_DOMAIN_SECURE');
    UPDATE ${TABLE_PREFIX}usermeta SET meta_value = REPLACE(meta_value, '$URL', '$NEW_DOMAIN_SECURE');
    UPDATE ${TABLE_PREFIX}comments SET comment_content = REPLACE(comment_content, '$URL', '$NEW_DOMAIN_SECURE');
    UPDATE ${TABLE_PREFIX}comments SET comment_author_url = REPLACE(comment_author_url, '$URL', '$NEW_DOMAIN_SECURE');
    UPDATE ${TABLE_PREFIX}links SET link_url = REPLACE(link_url, '$URL', '$NEW_DOMAIN_SECURE');
    UPDATE ${TABLE_PREFIX}links SET link_image = REPLACE(link_image, '$URL', '$NEW_DOMAIN_SECURE');
    " 2>/dev/null
done

# Fetch updated Site URL and Home URL after making changes
AFTER_SITE_URL=$(mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -h "$DB_HOST" -se "SELECT option_value FROM ${TABLE_PREFIX}options WHERE option_name='siteurl';")
AFTER_HOME_URL=$(mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -h "$DB_HOST" -se "SELECT option_value FROM ${TABLE_PREFIX}options WHERE option_name='home';")

# Final confirmation message
echo -e "\n✅ URLs have been updated successfully!"
echo -e "🔄 Updated Site URL: $BEFORE_SITE_URL → $AFTER_SITE_URL"
echo -e "🔄 Updated Home URL: $BEFORE_HOME_URL → $AFTER_HOME_URL"

# Run WP-CLI search-replace if available
if command -v wp &> /dev/null; then
    echo -e "\n🔄 Running WP-CLI search-replace..."
    wp search-replace "${OLD_DOMAIN_CLEAN}" "$NEW_DOMAIN_SECURE" --all-tables --precise --recurse-objects --allow-root --report-changed-only > wpcli_output.txt 2>/dev/null
    if [[ -s wpcli_output.txt ]]; then
        cat wpcli_output.txt
    else
        echo "✅ WP-CLI executed successfully. No additional changes were needed."
    fi
    rm -f wpcli_output.txt
else
    echo "⚠️ WP-CLI not found. Skipping WP-CLI search-replace."
fi

echo -e "\n🎉 Migration Completed: All URLs have been updated from $OLD_DOMAIN to $NEW_DOMAIN!"
