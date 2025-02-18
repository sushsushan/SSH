#!/bin/bash

# Colors
GREEN='\e[32m'
YELLOW='\e[33m'
CYAN='\e[36m'
RED='\e[31m'
RESET='\e[0m'

# Page settings
PAGE_SIZE=10
START_INDEX=0
CURRENT_DIR=$(pwd)

# Function to display files and folders
display_files() {
    clear
    echo -e "${CYAN}Current Directory: ${RESET}${PWD}"
    echo -e "${YELLOW}$(ls -ld "$PWD")${RESET}"
    echo "----------------------------------------"
    
    # Count total files and folders
    TOTAL_FILES=$(find . -maxdepth 1 -type f | wc -l)
    TOTAL_FOLDERS=$(find . -maxdepth 1 -type d | wc -l)
    
    # Show folder details
    echo -e "${GREEN}Folders:${RESET}"
    find . -maxdepth 1 -type d | tail -n +2 | awk '{print NR-1, $0}' | sed "s|^\./||" | nl -w2 -s'. '
    
    echo "----------------------------------------"
    
    # Show file details with size
    echo -e "${YELLOW}Files:${RESET}"
    find . -maxdepth 1 -type f | tail -n +2 | awk '{print NR-1, $0}' | xargs -I {} ls -lh --time-style=long-iso {} 2>/dev/null | awk '{print NR-1, $5, $6, $7, $9}' | nl -w2 -s'. '
    
    echo "----------------------------------------"
    
    # Show totals
    echo -e "${CYAN}Total Folders: $TOTAL_FOLDERS | Total Files: $TOTAL_FILES${RESET}"
    echo -e "${RED}Total Size: $(du -sh . | cut -f1)${RESET}"
    
    echo "----------------------------------------"
    echo "Options: [N]ext Page | [P]revious Page | [A]dd | [E]dit | [D]elete | [Q]uit"
}

# Pagination function
paginate() {
    FILE_LIST=$(ls -p | grep -v / | tail -n +"$((START_INDEX + 1))" | head -n "$PAGE_SIZE")
    FOLDER_LIST=$(ls -p | grep / | tail -n +"$((START_INDEX + 1))" | head -n "$PAGE_SIZE")
    
    display_files
}

# Function to add a file or folder
add_file_folder() {
    read -p "Enter 'file' or 'folder': " TYPE
    read -p "Enter name: " NAME
    if [ "$TYPE" == "file" ]; then
        echo -e "${YELLOW}Enter file contents (Ctrl+D to save):${RESET}"
        cat > "$NAME"
    elif [ "$TYPE" == "folder" ]; then
        mkdir -p "$NAME"
        echo -e "${GREEN}Folder '$NAME' created!${RESET}"
    else
        echo -e "${RED}Invalid type!${RESET}"
    fi
}

# Function to edit a file
edit_file() {
    read -p "Enter file name to edit: " FILE
    if [ -f "$FILE" ]; then
        echo -e "${YELLOW}Editing file (Ctrl+D to save and exit)${RESET}"
        cat >> "$FILE"
    else
        echo -e "${RED}File not found!${RESET}"
    fi
}

# Function to delete a file or folder
delete_file_folder() {
    read -p "Enter name of file/folder to delete: " NAME
    if [ -e "$NAME" ]; then
        rm -rf "$NAME"
        echo -e "${RED}Deleted '$NAME'${RESET}"
    else
        echo -e "${RED}Not found!${RESET}"
    fi
}

# Main loop
while true; do
    paginate
    read -n1 -p "Enter choice: " CHOICE
    echo ""
    
    case "$CHOICE" in
        n|N) START_INDEX=$((START_INDEX + PAGE_SIZE));;
        p|P) START_INDEX=$((START_INDEX - PAGE_SIZE));;
        a|A) add_file_folder;;
        e|E) edit_file;;
        d|D) delete_file_folder;;
        q|Q) exit 0;;
        *) echo -e "${RED}Invalid choice!${RESET}";;
    esac
done
