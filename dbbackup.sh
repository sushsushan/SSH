#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No color

# Create backup directory
mkdir -p ~/backup

while true; do
    clear
    echo -e "${YELLOW}========================================${NC}"
    echo -e "${GREEN}         MySQL Database Backup          ${NC}"
    echo -e "${YELLOW}========================================${NC}"
    
    # Fetch databases
    DB_LIST=$(uapi Mysql list_databases | grep -oP '(?<=database:\s).+')

    if [[ -z "$DB_LIST" ]]; then
        echo -e "${RED}❌ No databases found! Exiting...${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Available Databases:${NC}"
    echo -e "${GREEN}----------------------------------------${NC}"
    echo "$DB_LIST"
    echo -e "${GREEN}----------------------------------------${NC}"

    # Ask user for backup choice with validation
    while true; do
        echo -en "${YELLOW}Would you like to back up all databases? (y/yes or n/no): ${NC}"
        read CHOICE
        CHOICE=$(echo "$CHOICE" | tr '[:upper:]' '[:lower:]') # Convert input to lowercase

        case "$CHOICE" in
            y|yes) CHOICE="yes"; break ;;
            n|no) CHOICE="no"; break ;;
            *) echo -e "${RED}❌ Invalid input. Please enter 'y/yes' or 'n/no'.${NC}" ;;
        esac
    done

    USERNAME=$(whoami)
    BACKUP_DIR=~/backup
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

    if [[ "$CHOICE" == "yes" ]]; then
        echo -e "\n${GREEN}✔ Starting backup for all databases...${NC}\n"
        for DB_NAME in $DB_LIST; do
            DB_USER="${USERNAME}_$(openssl rand -hex 4)"
            DB_PASS=$(openssl rand -base64 12)
            
            uapi Mysql create_user name="$DB_USER" password="$DB_PASS" >/dev/null 2>&1
            uapi Mysql set_privileges_on_database database="$DB_NAME" user="$DB_USER" privileges="ALL PRIVILEGES" >/dev/null 2>&1
            
            BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_$TIMESTAMP.sql"
            echo -e "${YELLOW}Backing up database: ${NC}${DB_NAME}..."
            mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE" 2>/dev/null
            
            uapi Mysql delete_user name="$DB_USER" >/dev/null 2>&1
            BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
            echo -e "${GREEN}✔ Backup completed: $BACKUP_FILE (Size: $BACKUP_SIZE)${NC}"
            echo -e "${GREEN}----------------------------------------${NC}"
        done
    else
        while true; do
            echo -en "${YELLOW}Enter the database name to backup: ${NC}"
            read DB_NAME
            
            if echo "$DB_LIST" | grep -qw "$DB_NAME"; then
                DB_USER="${USERNAME}_$(openssl rand -hex 4)"
                DB_PASS=$(openssl rand -base64 12)
                
                uapi Mysql create_user name="$DB_USER" password="$DB_PASS" >/dev/null 2>&1
                uapi Mysql set_privileges_on_database database="$DB_NAME" user="$DB_USER" privileges="ALL PRIVILEGES" >/dev/null 2>&1
                
                BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_$TIMESTAMP.sql"
                echo -e "${YELLOW}Backing up database: ${NC}${DB_NAME}..."
                mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE" 2>/dev/null
                
                uapi Mysql delete_user name="$DB_USER" >/dev/null 2>&1
                BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
                echo -e "${GREEN}✔ Backup completed: $BACKUP_FILE (Size: $BACKUP_SIZE)${NC}"
                break
            else
                echo -e "${RED}❌ Error: Database '$DB_NAME' not found. Please enter a valid database name.${NC}"
            fi
        done
    fi
    
    echo -e "${YELLOW}========================================${NC}"
    
    # Ask user if they want to run another backup
    while true; do
        echo -en "${YELLOW}Would you like to take another backup? (y/yes or n/no): ${NC}"
        read REPEAT
        REPEAT=$(echo "$REPEAT" | tr '[:upper:]' '[:lower:]') # Convert input to lowercase

        case "$REPEAT" in
            y|yes) break ;;
            n|no)  
                echo -e "${GREEN}✅ Backup process completed. Exiting.${NC}"
                echo -e "${YELLOW}========================================${NC}"
                exit 0
                ;;
            *) echo -e "${RED}❌ Invalid input. Please enter 'y/yes' or 'n/no'.${NC}" ;;
        esac
    done
done
