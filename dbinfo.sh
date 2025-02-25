#!/bin/bash

# Define colors for formatting
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
CYAN='\033[1;36m'
RED='\033[1;31m'
NC='\033[0m' # No Color

# Fetch and display available databases
echo -e "${CYAN}Fetching available databases...${NC}"
DB_LIST=$(mysql -e "SHOW DATABASES;" -s --skip-column-names)

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

# Function to display query results in table format
print_table() {
    column -t -s $'\t' | sed 's/^/'"$GREEN"'/' | sed 's/$/'"$NC"'/'
}

# Display MySQL version and server settings
echo -e "${YELLOW}\n📌 MySQL Server Information:${NC}"
mysql -e "
SELECT 
    @@version AS 'MySQL Version',
    @@hostname AS 'Host Name',
    @@datadir AS 'Data Directory',
    @@max_connections AS 'Max Connections',
    @@query_cache_size AS 'Query Cache Size',
    @@slow_query_log AS 'Slow Query Log Enabled',
    @@long_query_time AS 'Slow Query Time (s)',
    @@wait_timeout AS 'Wait Timeout (s)',
    @@net_read_timeout AS 'Net Read Timeout (s)',
    @@net_write_timeout AS 'Net Write Timeout (s)',
    @@innodb_buffer_pool_size AS 'InnoDB Buffer Pool Size'
;" | print_table

# Display database size
echo -e "${YELLOW}\n📌 Database Size & Storage Information:${NC}"
mysql -e "
SELECT 
    table_schema AS 'Database Name',
    ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Total Size (MB)',
    DEFAULT_CHARACTER_SET_NAME AS 'Character Set',
    DEFAULT_COLLATION_NAME AS 'Collation'
FROM information_schema.SCHEMATA 
WHERE schema_name = '$DB_NAME'
GROUP BY table_schema;
" | print_table

# Display table details
echo -e "${YELLOW}\n📌 Tables & Their Details:${NC}"
mysql -D "$DB_NAME" -e "
SELECT 
    table_name AS 'Table Name',
    engine AS 'Engine',
    table_rows AS 'Row Count',
    ROUND((data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)',
    create_time AS 'Creation Time',
    table_collation AS 'Collation',
    auto_increment AS 'Auto Increment'
FROM information_schema.tables
WHERE table_schema='$DB_NAME'
ORDER BY table_name;
" | print_table

# Display column details
echo -e "${YELLOW}\n📌 Column Details for Each Table:${NC}"
mysql -D "$DB_NAME" -e "
SELECT 
    table_name AS 'Table Name',
    column_name AS 'Column Name',
    data_type AS 'Data Type',
    character_maximum_length AS 'Max Length',
    is_nullable AS 'Nullable',
    column_default AS 'Default Value',
    column_type AS 'Full Data Type',
    column_key AS 'Index Type'
FROM information_schema.columns
WHERE table_schema='$DB_NAME'
ORDER BY table_name, ordinal_position;
" | print_table

# Display indexes
echo -e "${YELLOW}\n📌 Indexes & Keys:${NC}"
mysql -D "$DB_NAME" -e "
SELECT 
    table_name AS 'Table Name',
    index_name AS 'Index Name',
    column_name AS 'Column Name',
    seq_in_index AS 'Sequence in Index',
    cardinality AS 'Cardinality',
    non_unique AS 'Unique (0=Yes, 1=No)',
    index_type AS 'Index Type'
FROM information_schema.statistics
WHERE table_schema='$DB_NAME'
ORDER BY table_name, index_name;
" | print_table

# Display user privileges
echo -e "${YELLOW}\n📌 User Privileges on Database:${NC}"
mysql -e "
SELECT 
    user AS 'User',
    host AS 'Host',
    Select_priv AS 'Select',
    Insert_priv AS 'Insert',
    Update_priv AS 'Update',
    Delete_priv AS 'Delete',
    Create_priv AS 'Create',
    Drop_priv AS 'Drop',
    Grant_priv AS 'Grant'
FROM mysql.db
WHERE db='$DB_NAME';
" | print_table

# Display global variables
echo -e "${YELLOW}\n📌 Global MySQL Variables:${NC}"
mysql -e "
SHOW GLOBAL VARIABLES;
" | print_table

# Display session variables
echo -e "${YELLOW}\n📌 Session Variables:${NC}"
mysql -e "
SHOW SESSION VARIABLES;
" | print_table

# Display current MySQL processes
echo -e "${YELLOW}\n📌 Active MySQL Processes:${NC}"
mysql -e "SHOW FULL PROCESSLIST;" | print_table

# Display slow queries & performance metrics
echo -e "${YELLOW}\n📌 Performance Metrics:${NC}"
mysql -e "
SHOW STATUS WHERE Variable_name IN (
    'Slow_queries', 'Threads_created', 'Threads_connected',
    'Connections', 'Aborted_connects', 'Select_full_join',
    'Select_scan', 'Sort_scan'
);
" | print_table

# Display system users with privileges
echo -e "${YELLOW}\n📌 MySQL Users & Privileges:${NC}"
mysql -e "SELECT User, Host FROM mysql.user;" | print_table

echo -e "${GREEN}\n✅ Database Analysis Completed.${NC}"
