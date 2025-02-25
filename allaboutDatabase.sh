#!/bin/bash

# Define colors for formatting
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RED='\033[1;31m'
NC='\033[0m' # No Color

# Fetch and display available databases
echo -e "${CYAN}Fetching available databases...${NC}"
DB_LIST=$(uapi Mysql list_databases | grep -oP '(?<=database:\s).+')

if [[ -z "$DB_LIST" ]]; then
    echo -e "${RED}No databases found.${NC}"
    exit 1
fi

echo -e "${GREEN}Available Databases:${NC}"
echo "$DB_LIST" | awk '{print "- " $0}'

# Prompt user for database selection
read -p "Enter the database name: " DB_NAME

# Validate user input
if ! echo "$DB_LIST" | grep -qx "$DB_NAME"; then
    echo -e "${RED}Invalid database name!${NC}"
    exit 1
fi

# Generate a random database user and password
DB_USER="$(whoami)_$(openssl rand -hex 4)"
DB_PASS=$(openssl rand -base64 12)

# Create MySQL user and grant privileges
uapi Mysql create_user name="$DB_USER" password="$DB_PASS" >/dev/null 2>&1
uapi Mysql set_privileges_on_database database="$DB_NAME" user="$DB_USER" privileges="ALL PRIVILEGES" >/dev/null 2>&1

# Function to display query results in table format
print_table() {
    column -t -s $'\t' | sed 's/^/'"$GREEN"'/' | sed 's/$/'"$NC"'/'
}

# Display MySQL version and global settings
echo -e "${YELLOW}\n📌 MySQL Server Information:${NC}"
mysql -u "$DB_USER" -p"$DB_PASS" -e "
SELECT 
    @@version AS 'MySQL Version',
    @@max_connections AS 'Max Connections',
    @@thread_cache_size AS 'Thread Cache Size',
    @@query_cache_size AS 'Query Cache Size',
    @@slow_query_log AS 'Slow Query Log Enabled',
    @@long_query_time AS 'Slow Query Time (s)',
    @@wait_timeout AS 'Wait Timeout (s)',
    @@net_read_timeout AS 'Net Read Timeout (s)',
    @@net_write_timeout AS 'Net Write Timeout (s)',
    @@innodb_buffer_pool_size AS 'InnoDB Buffer Pool Size',
    @@innodb_log_file_size AS 'InnoDB Log File Size'
;" | print_table

# Display database size
echo -e "${YELLOW}\n📌 Database Size & Usage:${NC}"
mysql -u "$DB_USER" -p"$DB_PASS" -e "
SELECT 
    table_schema AS 'Database Name',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Total Size (MB)',
    ROUND(SUM(data_free) / 1024 / 1024, 2) AS 'Unused Space (MB)'
FROM information_schema.tables 
WHERE table_schema = '$DB_NAME'
GROUP BY table_schema;
" | print_table

# Display table sizes before optimization
echo -e "${YELLOW}\n📌 Table Sizes Before Optimization:${NC}"
mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "
SELECT 
    table_name AS 'Table Name',
    ROUND((data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables
WHERE table_schema='$DB_NAME'
ORDER BY 2 DESC;
" | print_table

# Optimize all tables
echo -e "${CYAN}\n🔄 Optimizing Tables...${NC}"
TABLES=$(mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -Bse 'SHOW TABLES')

if [[ -z "$TABLES" ]]; then
    echo -e "${RED}No tables found in the database.${NC}"
else
    mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "OPTIMIZE TABLE $TABLES;" >/dev/null 2>&1
    echo -e "${GREEN}✅ Optimization Completed.${NC}"
fi

# Display table sizes after optimization
echo -e "${YELLOW}\n📌 Table Sizes After Optimization:${NC}"
mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "
SELECT 
    table_name AS 'Table Name',
    ROUND((data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)'
FROM information_schema.tables
WHERE table_schema='$DB_NAME'
ORDER BY 2 DESC;
" | print_table

# Display MySQL process list and slow queries
echo -e "${YELLOW}\n📌 Current MySQL Processes & Slow Queries:${NC}"
mysql -u "$DB_USER" -p"$DB_PASS" -e "
SHOW FULL PROCESSLIST;
SELECT COUNT(*) AS 'Total Slow Queries' FROM mysql.slow_log;
" | print_table

# Display user privileges
echo -e "${YELLOW}\n📌 Current User Privileges:${NC}"
mysql -u "$DB_USER" -p"$DB_PASS" -e "SHOW GRANTS FOR CURRENT_USER();" | print_table

# Display packet performance and NULL queries
echo -e "${YELLOW}\n📌 Performance Metrics (Packets & NULL Queries):${NC}"
mysql -u "$DB_USER" -p"$DB_PASS" -e "
SHOW STATUS WHERE Variable_name IN (
    'Bytes_received', 'Bytes_sent', 'Threads_created', 'Threads_connected',
    'Connections', 'Aborted_connects', 'Slow_queries', 'Select_full_join',
    'Select_full_range_join', 'Select_scan', 'Sort_scan'
);
" | print_table

# Cleanup: Delete the temporary MySQL user
uapi Mysql delete_user name="$DB_USER" >/dev/null 2>&1

echo -e "${GREEN}\n✅ Database Analysis & Optimization Completed. Temporary User Removed.${NC}"
