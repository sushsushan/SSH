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

    # Display table sizes before cleanup
    echo -e "\nTable sizes before cleanup:"
    mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "
    SELECT TABLE_NAME, 
           ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) AS Size_MB 
    FROM information_schema.TABLES 
    WHERE TABLE_SCHEMA='$DB_NAME' 
    ORDER BY Size_MB DESC;" 2>/dev/null

    # Identify cache tables
    CACHE_TABLES=$(mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -Bse "
        SELECT TABLE_NAME FROM information_schema.TABLES 
        WHERE TABLE_SCHEMA='$DB_NAME' 
        AND (TABLE_NAME LIKE '%cache%' 
        OR TABLE_NAME LIKE '%temp%' 
        OR TABLE_NAME LIKE '%session%' 
        OR TABLE_NAME LIKE '%log%' 
        OR TABLE_NAME LIKE '%transient%');" 2>/dev/null)

    if [ -n "$CACHE_TABLES" ]; then
        echo -e "\n🔍 The following tables seem to store cache or temporary data:"
        echo "$CACHE_TABLES"
        
        read -p "Do you want to clear the data in these tables? (y/n): " confirm
        if [[ "$confirm" == "y" ]]; then
            echo -e "\n🧹 Clearing cache tables..."
            for TABLE in $CACHE_TABLES; do
                mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "DELETE FROM $TABLE;" >/dev/null 2>&1
            done
            echo "✅ Cache cleared."
        else
            echo "❌ Skipping cache clearing."
        fi
    else
        echo -e "\n✅ No cache-related tables detected."
    fi

    # Optimize tables
    TABLES=$(mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -Bse 'SHOW TABLES' 2>/dev/null)

    if [ -n "$TABLES" ]; then
        echo -e "\n🔄 Optimizing tables..."
        for TABLE in $TABLES; do
            mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "OPTIMIZE TABLE $TABLE;" >/dev/null 2>&1
        done
        echo "✅ Optimization complete."
    fi

    # Display table sizes after cleanup
    echo -e "\nTable sizes after cleanup:"
    mysql -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "
    SELECT TABLE_NAME, 
           ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024, 2) AS Size_MB 
    FROM information_schema.TABLES 
    WHERE TABLE_SCHEMA='$DB_NAME' 
    ORDER BY Size_MB DESC;" 2>/dev/null

    # Remove temporary user
    uapi Mysql delete_user name="$DB_USER" >/dev/null 2>&1

    # Ask if the user wants to clean another database
    read -p "Would you like to optimize another database? (y/n): " choice
    if [[ "$choice" != "y" ]]; then
        echo "Exiting..."
        break
    fi
done
