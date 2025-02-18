#!/bin/bash

# Color Definitions
echo -e "\033]11;#300A24\007"

# Set Foreground (Text) Color to White (#FFFFFF)
echo -e "\033]10;#FFFFFF\007"

# Set Cursor Color to Green (#00FF00)
echo -e "\033]12;#00FF00\007"

# Set Cursor Type to Block
echo -e "\e[2 q"

# Clear screen to apply new colors immediately
clear

# Function to Display Directory Contents
display_files() {
    clear
    echo -e "${CYAN}Current Directory: ${RESET}${PWD}"
    echo -e "${BLUE}--------------------------------------------------------------${RESET}"

    # Get folder and file details
    FOLDERS=($(find "$PWD" -maxdepth 1 -type d | tail -n +2 | sort))
    FILES=($(find "$PWD" -maxdepth 1 -type f | sort))

    # Count total files and folders
    TOTAL_FOLDERS=${#FOLDERS[@]}
    TOTAL_FILES=${#FILES[@]}
    TOTAL_SIZE=$(du -sh "$PWD" | awk '{print $1}')

    echo -e "${GREEN}Total Folders: ${RESET}$TOTAL_FOLDERS | ${GREEN}Total Files: ${RESET}$TOTAL_FILES | ${GREEN}Total Size: ${RESET}$TOTAL_SIZE"
    echo -e "${BLUE}--------------------------------------------------------------${RESET}"

    # Display Folders on Left | Files on Right
    echo -e "${YELLOW}Folders:${RESET}                         ${MAGENTA}Files:${RESET}"
    echo -e "${BLUE}--------------------------------------------------------------${RESET}"

    # Find max count to align properly
    max_count=$((TOTAL_FOLDERS > TOTAL_FILES ? TOTAL_FOLDERS : TOTAL_FILES))

    for ((i = 0; i < max_count; i++)); do
        FOLDER_NAME="${FOLDERS[i]}"
        FILE_NAME="${FILES[i]}"

        # Formatting for better alignment
        printf "%-30s %s\n" "${FOLDER_NAME:-}" "${FILE_NAME:-}"
    done

    echo -e "${BLUE}--------------------------------------------------------------${RESET}"
}

# Function to Change Directory with Folder Listing
change_directory() {
    echo -e "${CYAN}Available Folders:${RESET}"
    
    # Display numbered list of directories
    local index=1
    for folder in "${FOLDERS[@]}"; do
        echo -e "${YELLOW}$index) $folder${RESET}"
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
