# Generate a unique staging folder inside public_html (or the main directory)
staging_folder_name="staging_$(shuf -i 10000-99999 -n 1)"
staging_folder="$main_path/$staging_folder_name"

# Create the staging directory
mkdir -p "$staging_folder" || handle_error "Failed to create staging directory."

# Copy WordPress files, excluding unnecessary ones
rsync -a --exclude="staging_*" "$main_path/" "$staging_folder/" || handle_error "Failed to copy files."

# Generate the correct staging site URL dynamically
staging_url="${wp_home}/${staging_folder_name}"

# Update URLs in the database correctly
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

# Display success message
echo "✅ Staging site successfully created!"
echo "📂 Staging Path: $staging_folder"
echo "🌍 Staging URL: $staging_url"
