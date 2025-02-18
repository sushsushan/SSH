#!/bin/bash

while true; do
    clear
    echo "Fetching available databases..."
    
    DB_LIST=$(uapi Mysql list_databases | grep -oP '(?<=database:\s).+')
    
    if [ -z "$DB_LIST" ]; then
        echo "No databases found."
        exit 1
    fi

    echo "$DB_LIST"
    
    read -p "Enter database name: " DB_NAME
    
    if ! echo "$DB_LIST" | grep -q "^$DB_NAME$"; then
        echo "Error: Database '$DB_NAME' does not exist."
        continue
    fi

    DB_USER="$(whoami)_$(openssl rand -hex 4)"
    DB_PASS=$(openssl rand -base64 12)

    # Create temporary user
    uapi Mysql create_user name="$DB_USER" password="$DB_PASS" >/dev/null 2>&1
    uapi Mysql set_privileges_on_database database="$DB_NAME" user="$DB_USER" privileges="ALL PRIVILEGES" >/dev/null 2>&1

    # Display table sizes before optimization
    echo -e "\nTable sizes before optimization:"
    mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "
    SELECT TABLE_NAME, 
           ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) AS Size_MB 
    FROM information_schema.TABLES 
    WHERE TABLE_SCHEMA='$DB_NAME' 
    ORDER BY Size_MB DESC;" 2>/dev/null

    # Optimize tables
    TABLES=$(mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -Bse 'SHOW TABLES' 2>/dev/null)
    if [ -n "$TABLES" ]; then
        mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "OPTIMIZE TABLE $TABLES;" >/dev/null 2>&1
    fi

    # Display table sizes after optimization
    echo -e "\nTable sizes after optimization:"
    mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "
    SELECT TABLE_NAME, 
           ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) AS Size_MB 
    FROM information_schema.TABLES 
    WHERE TABLE_SCHEMA='$DB_NAME' 
    ORDER BY Size_MB DESC;" 2>/dev/null

    # Remove temporary user
    uapi Mysql delete_user name="$DB_USER" >/dev/null 2>&1

    # Ask if the user wants to optimize another database
    read -p "Would you like to optimize another database? (y/n): " choice
    if [[ "$choice" != "y" ]]; then
        echo "Exiting..."
        break
    fi
done
