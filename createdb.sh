#!/bin/bash

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get the current system user
HOST_USER=$(whoami)

# Function to check if a database exists
db_exists() {
    local db_name="$1"
    uapi Mysql list_databases | grep -q "${HOST_USER}_${db_name}"
}

# Prompt user for choice
echo -e "${YELLOW}1) System-generated DB name/user  2) Enter your own DB name/user${NC}"
read -p "Choose (1/2): " choice

if [[ "$choice" == "1" ]]; then
    DB_NAME="db_$(date +%s)"
else
    while true; do
        read -p "Enter DB name: " DB_NAME
        if db_exists "$DB_NAME"; then
            echo -e "${RED}Database '${HOST_USER}_${DB_NAME}' already exists. Please choose another name.${NC}"
        else
            break
        fi
    done
fi

# Define database credentials
DB_USER="${HOST_USER}_${DB_NAME}"
DB_PASS=$(openssl rand -base64 12)
FULL_DB_NAME="${HOST_USER}_${DB_NAME}"

# Create the database
echo -e "${YELLOW}Creating database...${NC}"
uapi Mysql create_database name="$FULL_DB_NAME"

# Create the user
echo -e "${YELLOW}Creating user...${NC}"
uapi Mysql create_user name="$DB_USER" password="$DB_PASS"

# Set privileges
echo -e "${YELLOW}Setting privileges...${NC}"
uapi Mysql set_privileges_on_database database="$FULL_DB_NAME" user="$DB_USER" privileges="ALL PRIVILEGES"

# Display credentials
echo -e "${GREEN}Database created successfully!${NC}"
echo -e "${GREEN}Database: ${FULL_DB_NAME}${NC}"
echo -e "${GREEN}User: ${DB_USER}${NC}"
echo -e "${GREEN}Password: ${DB_PASS}${NC}"
