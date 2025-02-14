#!/bin/bash

# Create backup directory
mkdir -p ~/backup

while true; do
    echo "========================================"
    echo "         MySQL Database Backup          "
    echo "========================================"
    echo "Available Databases:"
    echo "----------------------------------------"
    DB_LIST=$(uapi Mysql list_databases | grep -oP '(?<=database:\s).+')
    echo "$DB_LIST"
    echo "----------------------------------------"

    echo -n "Would you like to take a backup of all databases? (yes/no): "
    read CHOICE

    USERNAME=$(whoami)
    BACKUP_DIR=~/backup
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

    if [[ "$CHOICE" == "yes" ]]; then
        echo "\nStarting backup for all databases...\n"
        for DB_NAME in $DB_LIST; do
            DB_USER="${USERNAME}_$(openssl rand -hex 4)"
            DB_PASS=$(openssl rand -base64 12)
            
            uapi Mysql create_user name="$DB_USER" password="$DB_PASS" >/dev/null 2>&1
            uapi Mysql set_privileges_on_database database="$DB_NAME" user="$DB_USER" privileges="ALL PRIVILEGES" >/dev/null 2>&1
            
            BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_$TIMESTAMP.sql"
            echo "Backing up database: $DB_NAME..."
            mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE" 2>/dev/null
            
            uapi Mysql delete_user name="$DB_USER" >/dev/null 2>&1
            BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
            echo "✔ Backup completed: $BACKUP_FILE (Size: $BACKUP_SIZE)"
            echo "----------------------------------------"
        done
    else
        echo -n "Enter the database name to backup: "
        read DB_NAME
        
        if echo "$DB_LIST" | grep -qw "$DB_NAME"; then
            DB_USER="${USERNAME}_$(openssl rand -hex 4)"
            DB_PASS=$(openssl rand -base64 12)
            
            uapi Mysql create_user name="$DB_USER" password="$DB_PASS" >/dev/null 2>&1
            uapi Mysql set_privileges_on_database database="$DB_NAME" user="$DB_USER" privileges="ALL PRIVILEGES" >/dev/null 2>&1
            
            BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_$TIMESTAMP.sql"
            echo "Backing up database: $DB_NAME..."
            mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE" 2>/dev/null
            
            uapi Mysql delete_user name="$DB_USER" >/dev/null 2>&1
            BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
            echo "✔ Backup completed: $BACKUP_FILE (Size: $BACKUP_SIZE)"
        else
            echo "❌ Error: Database '$DB_NAME' not found."
        fi
    fi
    
    echo "========================================"
    echo -n "Would you like to take another backup? (yes/no): "
    read REPEAT
    if [[ "$REPEAT" != "yes" ]]; then
        echo "✅ Backup process completed. Redirecting to home..."
        echo "========================================"
        exec ~/home.sh
    fi

done
