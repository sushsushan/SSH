#!/bin/bash

# Fetch and display available databases
echo "Fetching available databases..."
DB_LIST=$(uapi Mysql list_databases | grep -oP '(?<=database:\s).+')

if [[ -z "$DB_LIST" ]]; then
    echo "No databases found."
    exit 1
fi

echo "Available databases:"
echo "$DB_LIST"

# Prompt user for database selection
read -p "Enter the database name: " DB_NAME

# Validate user input
if ! echo "$DB_LIST" | grep -qx "$DB_NAME"; then
    echo "Invalid database name!"
    exit 1
fi

# Generate a random database user and password
DB_USER="$(whoami)_$(openssl rand -hex 4)"
DB_PASS=$(openssl rand -base64 12)

# Create MySQL user and grant privileges
uapi Mysql create_user name="$DB_USER" password="$DB_PASS" >/dev/null 2>&1
uapi Mysql set_privileges_on_database database="$DB_NAME" user="$DB_USER" privileges="ALL PRIVILEGES" >/dev/null 2>&1

# Display table sizes before optimization
echo "Table sizes before optimization:"
mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "
SELECT TABLE_NAME, 
       ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) AS Size_MB 
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA='$DB_NAME' 
ORDER BY Size_MB DESC;"

# Optimize all tables
echo "Optimizing tables..."
TABLES=$(mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -Bse 'SHOW TABLES')

if [[ -z "$TABLES" ]]; then
    echo "No tables found in the database."
else
    mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "OPTIMIZE TABLE $TABLES;"
fi

# Display table sizes after optimization
echo "Table sizes after optimization:"
mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "
SELECT TABLE_NAME, 
       ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) AS Size_MB 
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA='$DB_NAME' 
ORDER BY Size_MB DESC;"

# Cleanup: Delete the temporary MySQL user
uapi Mysql delete_user name="$DB_USER" >/dev/null 2>&1

echo "Optimization complete. Temporary user removed."
