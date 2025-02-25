#!/bin/bash

# Function to fetch document root for a given domain
get_document_root() {
    local domain="$1"
    uapi DomainInfo domains_data | grep -A10 "domain: $domain" | grep "documentroot:" | awk '{print $2}'
}

# Function to extract DB credentials from configuration files
extract_db_credentials() {
    local config_file="$1"
    
    # Extract values based on common patterns
    db_name=$(grep -E "DB_NAME|database" "$config_file" | head -1 | sed -E "s/.*['\"]([^'\"]+)['\"].*/\1/")
    db_user=$(grep -E "DB_USER|username" "$config_file" | head -1 | sed -E "s/.*['\"]([^'\"]+)['\"].*/\1/")
    db_pass=$(grep -E "DB_PASSWORD|password" "$config_file" | head -1 | sed -E "s/.*['\"]([^'\"]+)['\"].*/\1/")
    db_host=$(grep -E "DB_HOST|host" "$config_file" | head -1 | sed -E "s/.*['\"]([^'\"]+)['\"].*/\1/")
    
    echo "Found Configuration File: $config_file"
    echo "Database Name: $db_name"
    echo "Database User: $db_user"
    echo "Database Password: $db_pass"
    echo "Database Host: $db_host"
    echo "--------------------------------------"
}

# Get list of databases
echo "Fetching list of databases..."
db_list=$(uapi Mysql list_databases | grep -oP '(?<=database:\s).+')

# Get list of database users
echo "Fetching list of database users..."
db_users=$(uapi Mysql list_users | grep -oP '(?<=\buser:\s).+')

# Prompt user for domain name
read -p "Enter the domain name: " domain_name

# Get document root
doc_root=$(get_document_root "$domain_name")

if [[ -z "$doc_root" ]]; then
    echo "Error: Unable to find document root for $domain_name."
    exit 1
fi

echo "Document Root for $domain_name: $doc_root"

# Search for configuration files
echo "Searching for CMS configuration files in $doc_root..."
config_files=$(find "$doc_root" -type f \( -name "wp-config.php" -o -name "configuration.php" -o -name "config.php" -o -name "settings.php" -o -name "database.php" -o -name "db.php" \) 2>/dev/null)

if [[ -z "$config_files" ]]; then
    echo "No known CMS configuration files found."
    exit 1
fi

# Extract and display database credentials
for config_file in $config_files; do
    extract_db_credentials "$config_file"
done
