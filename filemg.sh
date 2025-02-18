#!/bin/bash

# Color Definitions
GREEN='\e[32m'
YELLOW='\e[33m'
CYAN='\e[36m'
RED='\e[31m'
BLUE='\e[34m'
MAGENTA='\e[35m'
RESET='\e[0m'

# Current Directory
CURRENT_DIR=$(pwd)
PAGE_SIZE=10  # Number of files/folders to show per page
START_INDEX=0

# Function to Display Directory Contents
display_files() {
    clear
    echo -e "${CYAN}Current Directory: ${RESET}${PWD}"
    echo -e "${BLUE}-----------------------------------------------------------${RESET}"

    # Get folder and file details
    FOLDERS=($(find "$PWD" -maxdepth 1 -type d | tail -n +2))
    FILES=($(find "$PWD" -maxdepth 1 -type f))

    # Count total files and folders
    TOTAL_FOLDERS=${#FOLDERS[@]}
    TOTAL_FILES=${#FILES[@]}
    TOTAL_SIZE=$(du -sh "$PWD" | awk '{print $1}')

    echo -e "${GREEN}Total Folders: ${RESET}$TOTAL_FOLDERS | ${GREEN}Total Files: ${RESET}$TOTAL_FILES | ${GREEN}Total Size: ${RESET}$TOTAL_SIZE"
    echo -e "${BLUE}-----------------------------------------------------------${RESET}"

    # Display Folders on Left | Files on Right
    echo -e "${YELLOW}Folders:${RESET}                        ${MAGENTA}Files:${RESET}"
    echo -e "${BLUE}-----------------------------------------------------------${RESET}"

    # Show a maximum of PAGE_SIZE items
    for ((i = 0; i < PAGE_SIZE; i++)); do
        FOLDER_NAME="${FOLDERS[i]}"
        FILE_NAME="${FILES[i]}"

        # Formatting for better alignment
        printf "%-30s %s\n" "${FOLDER_NAME:-}" "${FILE_NAME:-}"
    done

    echo -e "${BLUE}-----------------------------------------------------------${RESET}"
}

# Function to Change Directory with Folder Listing
change_directory() {
    echo -e "${CYAN}Available Folders:${RESET}"
    
    # Display numbered list of directories
    local index=1
    for folder in "${FOLDERS[@]}"; do
        echo -e "$index) $folder"
        ((index++))
    done

    read -p "Enter folder number to navigate (.. to go back): " CHOICE

    if [[ "$CHOICE" == ".." ]]; then
        cd ..
    elif [[ "$CHOICE" -gt 0 && "$CHOICE" -le "${#FOLDERS[@]}" ]]; then
        cd "${FOLDERS[CHOICE - 1]}"
    else
        echo -e "${RED}Invalid choice!${RESET}"
    fi
}

# Function to Add a File
add_file() {
    read -p "Enter new file name: " FILE_NAME
    if [[ -e "$FILE_NAME" ]]; then
        echo -e "${RED}File already exists!${RESET}"
    else
        echo -e "${CYAN}Enter file content. Press Ctrl+D to save.${RESET}"
        cat > "$FILE_NAME"
        echo -e "${GREEN}File created successfully!${RESET}"
    fi
}

# Function to Edit a File
edit_file() {
    read -p "Enter the file name to edit: " FILE_NAME
    if [[ ! -f "$FILE_NAME" ]]; then
        echo -e "${RED}File does not exist!${RESET}"
    else
        echo -e "${CYAN}Editing file. Press Ctrl+D to save.${RESET}"
        cat >> "$FILE_NAME"
        echo -e "${GREEN}File updated successfully!${RESET}"
    fi
}

# Function to Delete a File/Folder
delete_item() {
    read -p "Enter file/folder name to delete: " ITEM
    if [[ -e "$ITEM" ]]; then
        rm -rf "$ITEM"
        echo -e "${GREEN}Deleted successfully!${RESET}"
    else
        echo -e "${RED}Item not found!${RESET}"
    fi
}

# Pagination Functions (for Large Directories)
next_page() {
    if [[ $START_INDEX -lt $(($TOTAL_FOLDERS + $TOTAL_FILES - PAGE_SIZE)) ]]; then
        START_INDEX=$((START_INDEX + PAGE_SIZE))
    else
        echo -e "${RED}Already on last page!${RESET}"
    fi
}

previous_page() {
    if [[ $START_INDEX -ge $PAGE_SIZE ]]; then
        START_INDEX=$((START_INDEX - PAGE_SIZE))
    else
        echo -e "${RED}Already on first page!${RESET}"
    fi
}

# Main Loop
while true; do
    display_files
    echo -e "${CYAN}Options:${RESET}"
    echo -e " (a) Add File  |  (e) Edit File  |  (d) Delete File/Folder  |  (cd) Change Directory  |  (q) Quit"
    read -p "Enter option: " OPTION

    case $OPTION in
        a) add_file ;;
        e) edit_file ;;
        d) delete_item ;;
        cd) change_directory ;;
        q) break ;;
        *) echo -e "${RED}Invalid option!${RESET}" ;;
    esac
done
