#!/bin/bash

# Color codes for better visibility
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

# Get the cPanel username
HOST_USER=$(whoami)

# Function to check if a database exists
function database_exists() {
    local db_name=$1
    existing_dbs=$(uapi Mysql list_databases | grep -oP '(?<=database:\s).+')
    if echo "$existing_dbs" | grep -q "^${db_name}$"; then
        return 0  # Database exists
    else
        return 1  # Database does not exist
    fi
}

# Prompt user for database creation method
echo -e "${BLUE}Database Creation Tool${RESET}"
echo -e "${YELLOW}1) System-generated DB name${RESET}"
echo -e "${YELLOW}2) Enter your own DB name${RESET}"
read -p "Choose (1/2): " choice

if [[ "$choice" == "1" ]]; then
    while true; do
        DB_NAME="db_$(date +%s)"
        FULL_DB_NAME="${HOST_USER}_${DB_NAME}"
        if database_exists "$FULL_DB_NAME"; then
            echo -e "${RED}Generated database name already exists, trying again...${RESET}"
            sleep 1
        else
            break
        fi
    done
elif [[ "$choice" == "2" ]]; then
    while true; do
        read -p "Enter DB name: " DB_NAME
        FULL_DB_NAME="${HOST_USER}_${DB_NAME}"
        if database_exists "$FULL_DB_NAME"; then
            echo -e "${RED}Database already exists! Please enter a different name.${RESET}"
        else
            break
        fi
    done
else
    echo -e "${RED}Invalid choice! Exiting...${RESET}"
    exit 1
fi

# Generate a strong random password
DB_PASS=$(openssl rand -base64 12)

# Define full DB username
DB_USER="${HOST_USER}_${DB_NAME}"

# Create the database
echo -e "${GREEN}Creating database...${RESET}"
if uapi Mysql create_database name="$FULL_DB_NAME" >/dev/null 2>&1; then
    echo -e "${GREEN}Database created successfully: ${FULL_DB_NAME}${RESET}"
else
    echo -e "${RED}Failed to create database!${RESET}"
    exit 1
fi

# Create the database user
echo -e "${GREEN}Creating user...${RESET}"
if uapi Mysql create_user name="$DB_USER" password="$DB_PASS" >/dev/null 2>&1; then
    echo -e "${GREEN}User created successfully: ${DB_USER}${RESET}"
else
    echo -e "${RED}Failed to create database user!${RESET}"
    exit 1
fi

# Set privileges
echo -e "${GREEN}Setting privileges...${RESET}"
if uapi Mysql set_privileges_on_database database="$FULL_DB_NAME" user="$DB_USER" privileges="ALL PRIVILEGES" >/dev/null 2>&1; then
    echo -e "${GREEN}Privileges assigned successfully.${RESET}"
else
    echo -e "${RED}Failed to set privileges!${RESET}"
    exit 1
fi

# Display the final details
echo -e "${BLUE}--------------------------------${RESET}"
echo -e "${GREEN}Database Name:${RESET} $FULL_DB_NAME"
echo -e "${GREEN}Username:${RESET} $DB_USER"
echo -e "${GREEN}Password:${RESET} $DB_PASS"
echo -e "${BLUE}--------------------------------${RESET}"

exit 0
