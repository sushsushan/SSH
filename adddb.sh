#!/bin/bash

# Define color codes
RED='\033[1;31m'
GREEN='\033[1;32m'
BLUE='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the current system user
HOST_USER=$(whoami)

# Function to check if a database exists
db_exists() {
    local db_name="$1"
    uapi Mysql list_databases | grep -q "${HOST_USER}_${db_name}"
}

clear
# Display menu with clear instructions
while true; do
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${YELLOW}  DATABASE CREATION TOOL${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${GREEN}1) Auto-generate database name and user${NC}"
    echo -e "${GREEN}2) Enter your own database name and user${NC}"
    echo -e "${BLUE}=========================================${NC}"
    read -p "Please select an option (1/2): " choice

    if [[ "$choice" == "1" ]]; then
        DB_NAME="db_$(date +%s)"
        break
    elif [[ "$choice" == "2" ]]; then
        while true; do
            read -p "Enter your desired database name: " DB_NAME
            if db_exists "$DB_NAME"; then
                echo -e "${RED}Database '${HOST_USER}_${DB_NAME}' already exists. Please choose another name.${NC}"
            else
                break
            fi
        done
        break
    else
        echo -e "${RED}Invalid selection! Please choose either 1 or 2.${NC}"
    fi
done

# Define database credentials
DB_USER="${HOST_USER}_${DB_NAME}"
DB_PASS=$(openssl rand -base64 12)
FULL_DB_NAME="${HOST_USER}_${DB_NAME}"

# Creating database, user, and setting privileges silently
uapi Mysql create_database name="$FULL_DB_NAME" >/dev/null 2>&1
uapi Mysql create_user name="$DB_USER" password="$DB_PASS" >/dev/null 2>&1
uapi Mysql set_privileges_on_database database="$FULL_DB_NAME" user="$DB_USER" privileges="ALL PRIVILEGES" >/dev/null 2>&1

# Display results in a formatted and visually appealing manner
echo -e "${BLUE}=========================================${NC}"
echo -e "${GREEN}✅ Database created successfully!${NC}"
echo -e "${BLUE}=========================================${NC}"
echo -e "${YELLOW}📌 Database Name : ${NC}${GREEN}${FULL_DB_NAME}${NC}"
echo -e "${YELLOW}📌 Username      : ${NC}${GREEN}${DB_USER}${NC}"
echo -e "${YELLOW}📌 Password      : ${NC}${GREEN}${DB_PASS}${NC}"
echo -e "${BLUE}=========================================${NC}"
