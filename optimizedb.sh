#!/bin/bash

# Fetch available databases
echo "Fetching available databases..."
uapi Mysql list_databases | grep -oP '(?<=database:\s).+'
read -p "Enter database name: " DB_NAME

# Generate temporary DB user and password
DB_USER="$(whoami)_$(openssl rand -hex 4)"
DB_PASS=$(openssl rand -base64 12)

# Create the temporary database user
uapi Mysql create_user name="$DB_USER" password="$DB_PASS" >/dev/null 2>&1
uapi Mysql set_privileges_on_database database="$DB_NAME" user="$DB_USER" privileges="ALL PRIVILEGES" >/dev/null 2>&1

# Function to execute MySQL queries safely
execute_query() {
    mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "$1"
}

# Display table sizes before optimization
echo "Table sizes before optimization:"
execute_query "SELECT TABLE_NAME, ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) AS Size_MB FROM information_schema.TABLES WHERE TABLE_SCHEMA='$DB_NAME' ORDER BY Size_MB DESC;"

# Optimize all tables
echo "Optimizing tables..."
execute_query "OPTIMIZE TABLE $(execute_query 'SHOW TABLES' | awk '{print $1}' | tr '\n' ',' | sed 's/,$//');"

# Repair all tables
echo "Repairing tables..."
execute_query "REPAIR TABLE $(execute_query 'SHOW TABLES' | awk '{print $1}' | tr '\n' ',' | sed 's/,$//');"

# Remove old cached data (modify this query as per your database structure)
echo "Removing cached data..."
execute_query "DELETE FROM cache_table WHERE last_accessed < NOW() - INTERVAL 30 DAY;"
execute_query "DELETE FROM sessions WHERE last_updated < NOW() - INTERVAL 30 DAY;"

# Purge orphaned data (Modify based on your table structure)
echo "Removing orphaned data..."
execute_query "DELETE FROM orders WHERE user_id NOT IN (SELECT id FROM users);"
execute_query "DELETE FROM logs WHERE created_at < NOW() - INTERVAL 90 DAY;"

# Display table sizes after optimization
echo "Table sizes after optimization:"
execute_query "SELECT TABLE_NAME, ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) AS Size_MB FROM information_schema.TABLES WHERE TABLE_SCHEMA='$DB_NAME' ORDER BY Size_MB DESC;"

# Delete temporary DB user
uapi Mysql delete_user name="$DB_USER" >/dev/null 2>&1

echo "Database optimization completed successfully!"
