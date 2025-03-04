#!/bin/bash

# Enable colors
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
CYAN="\e[36m"
BOLD="\e[1m"
RESET="\e[0m"

# Welcome message
clear
echo -e "${CYAN}========================================${RESET}"
echo -e "${BOLD}${GREEN}   Welcome to the Advanced DB Backup Tool${RESET}"
echo -e "${CYAN}========================================${RESET}"
echo ""

# Fetch the list of databases
DB_LIST=$(uapi Mysql list_databases | grep -oP '(?<=database:\s).+')

# Check if databases exist
if [ -z "$DB_LIST" ]; then
    echo -e "${RED}Error: No databases found!${RESET}"
    exit 1
fi

# Display available databases
echo -e "${YELLOW}Available Databases:${RESET}"
echo -e "${BLUE}$DB_LIST${RESET}"
echo ""
echo -e "${CYAN}Enter '1' to back up ALL databases or type a specific database name:${RESET}"
read -p ">> " DB_CHOICE

# Get the username
USERNAME=$(whoami)

# Create backup directory
BACKUP_DIR=~/backup
mkdir -p "$BACKUP_DIR"

# Function to show an animated loading effect
loading_animation() {
    local SPINNER="/-\|"
    local i=0
    while true; do
        echo -ne "${CYAN}Processing backup... ${SPINNER:i++%${#SPINNER}:1} \r${RESET}"
        sleep 0.2
    done
}

# Store backup results if user selects option 1
declare -A BACKUP_RESULTS

# Function to back up a database
backup_database() {
    local DB_NAME=$1
    local DB_USER="${USERNAME}_$(openssl rand -hex 4)"
    local DB_PASS=$(openssl rand -base64 12)
    local BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_$(date +"%Y%m%d_%H%M%S").sql"

    # Create temporary database user
    uapi Mysql create_user name="$DB_USER" password="$DB_PASS" >/dev/null 2>&1
    uapi Mysql set_privileges_on_database database="$DB_NAME" user="$DB_USER" privileges="ALL PRIVILEGES" >/dev/null 2>&1

    # Start the loading animation in the background
    loading_animation &
    LOADING_PID=$!

    # Perform the backup
    mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$BACKUP_FILE" 2>/dev/null

    # Stop the loading animation
    kill $LOADING_PID >/dev/null 2>&1
    wait $LOADING_PID 2>/dev/null

    # Delete temporary database user
    uapi Mysql delete_user name="$DB_USER" >/dev/null 2>&1

    # Get backup size
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)

    # Display immediate progress if backing up all databases
    if [ "$DB_CHOICE" == "1" ]; then
        echo -e "${GREEN}✔ Database '${DB_NAME}' backed up successfully.${RESET}"
    fi

    # Store results if backing up all databases
    if [ "$DB_CHOICE" == "1" ]; then
        BACKUP_RESULTS["$DB_NAME"]="$BACKUP_FILE ($BACKUP_SIZE)"
    else
        # Display details for single database backup
        echo -e "${BOLD}${GREEN}✔ Backup completed successfully!${RESET}"
        echo -e "${CYAN}----------------------------------------${RESET}"
        echo -e "${BOLD}📂 Backup File: ${RESET}${BLUE}$BACKUP_FILE${RESET}"
        echo -e "${BOLD}📏 Backup Size: ${RESET}${YELLOW}$BACKUP_SIZE${RESET}"
        echo -e "${BOLD}🛠 Temporary user removed${RESET}"
        echo -e "${CYAN}----------------------------------------${RESET}"
        echo ""
    fi
}

# Backup process based on user input
if [ "$DB_CHOICE" == "1" ]; then
    echo -e "${GREEN}Backing up ALL databases...${RESET}"
    for DB_NAME in $DB_LIST; do
        backup_database "$DB_NAME"
    done

    # Display summary at the end
    echo -e "\n${BOLD}${GREEN}🎉 Backup process completed for all databases!${RESET}"
    echo -e "${CYAN}----------------------------------------${RESET}"
    printf "${BOLD}%-25s %-50s %-10s${RESET}\n" "Database Name" "Backup Path" "Size"
    echo -e "${CYAN}----------------------------------------${RESET}"
    for DB in "${!BACKUP_RESULTS[@]}"; do
        printf "%-25s %-50s\n" "$DB" "${BACKUP_RESULTS[$DB]}"
    done
    echo -e "${CYAN}----------------------------------------${RESET}\n"
else
    if echo "$DB_LIST" | grep -q "^$DB_CHOICE$"; then
        backup_database "$DB_CHOICE"
    else
        echo -e "${RED}Error: Database '${DB_CHOICE}' not found!${RESET}"
        exit 1
    fi
fi

echo -e "${BOLD}${GREEN}✅ All backup operations completed successfully!${RESET}"
