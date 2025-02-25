#!/bin/bash

# Welcome Message
echo "====================================="
echo "      Database Backup Tool          "
echo "====================================="

echo "Fetching available databases..."

# Fetch existing databases
EXISTING_DBS=$(uapi Mysql list_databases | grep -oP '(?<=database:\s).+')

# Display Databases in a Clear Table Format
echo "---------------------------------------------"
echo "|          Available Databases              |"
echo "---------------------------------------------"
index=1
while IFS= read -r db; do
    printf "| %2d. %-35s |
" "$index" "$db"
    ((index++))
done <<< "$EXISTING_DBS"
echo "---------------------------------------------"

# Prompt User for Database Selection
while true; do
    read -p "Enter the database name you want to back up: " DB_NAME
    if echo "$EXISTING_DBS" | grep -q "^$DB_NAME$"; then
        break
    else
        echo "[ERROR] Database '$DB_NAME' not found. Please enter a valid database name."
    fi
done

# Generate Backup Directory
mkdir -p ~/backup
BACKUP_FILE=~/backup/"$DB_NAME"_$(date +"%Y%m%d_%H%M%S").sql

echo "Starting backup for database '$DB_NAME', please wait..."
mysqldump "$DB_NAME" > "$BACKUP_FILE" 2>/dev/null

# Display Backup Details
BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo "====================================="
echo "         Backup Completed           "
echo "====================================="
echo "Backup File: $BACKUP_FILE"
echo "Backup Size: $BACKUP_SIZE"
echo "====================================="
echo "Process completed! Have a great day!"
