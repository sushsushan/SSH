#!/bin/bash

echo "========================================"
echo "      Welcome to DB Backup Tool"
echo "========================================"

# Fetch the list of databases
DB_LIST=$(uapi Mysql list_databases | grep -oP '(?<=database:\s).+')

# Check if databases exist
if [ -z "$DB_LIST" ]; then
    echo "No databases found!"
    exit 1
fi

echo "Available Databases:"
echo "$DB_LIST"
echo ""

# Ask user to choose backup option
echo "Choose an option:"
echo "1) Backup all databases"
echo "2) Select specific databases to back up"
read -p "Enter your choice (1 or 2): " CHOICE

# Get the username
USERNAME=$(whoami)

# Create backup directory
BACKUP_DIR=~/backup
mkdir -p "$BACKUP_DIR"

# Function to backup a database
backup_database() {
    local DB_NAME=$1
    local DB_USER="${USERNAME}_$(openssl rand -hex 4)"
    local DB_PASS=$(openssl rand -base64 12)

    echo "Creating temporary database user for $DB_NAME..."
    uapi Mysql create_user name="$DB_USER" password="$DB_PASS" >/dev/null 2>&1
    uapi Mysql set_privileges_on_database database="$DB_NAME" user="$DB_USER" privileges="ALL PRIVILEGES" >/dev/null 2>&1

    BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_$(date +"%Y%m%d_%H%M%S").sql"
    echo "Starting backup for $DB_NAME..."
    mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE" 2>/dev/null

    uapi Mysql delete_user name="$DB_USER" >/dev/null 2>&1

    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo "Backup completed: $BACKUP_FILE ($BACKUP_SIZE)"
    echo "Temporary database user removed."
}

# Process user choice
if [ "$CHOICE" == "1" ]; then
    echo "Backing up all databases..."
    for DB_NAME in $DB_LIST; do
        backup_database "$DB_NAME"
    done
elif [ "$CHOICE" == "2" ]; then
    echo "Enter the names of databases to back up (separated by space):"
    read -p "> " SELECTED_DB
    for DB_NAME in $SELECTED_DB; do
        if echo "$DB_LIST" | grep -q "^$DB_NAME$"; then
            backup_database "$DB_NAME"
        else
            echo "Warning: Database $DB_NAME does not exist!"
        fi
    done
else
    echo "Invalid option selected. Exiting."
    exit 1
fi

echo "Backup process completed successfully!"
