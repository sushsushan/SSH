#!/bin/bash

# Define Colors
GREEN="\033[1;32m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
MAGENTA="\033[1;35m"
RED="\033[1;31m"
RESET="\033[0m"

# Display Current Directory
echo -e "\n${GREEN}Current Directory:${RESET} $(pwd)"

# Read Directory Input
read -rp "Enter directory to backup: " dir
dir="$(realpath -m "$dir")"

# Validate Directory
if [[ ! -d "$dir" ]]; then
    echo -e "${RED}Error: Invalid directory!${RESET}\n"
    exit 1
fi

# Get Total Directory Size
total_size=$(du -sh "$dir" | cut -f1)
echo -e "\n${BLUE}Total Size of Directory:${RESET} ${CYAN}$dir${RESET} ${YELLOW}($total_size)${RESET}"

# List Files and Directories in a Proper Table
echo -e "\n${CYAN}Contents of Directory (Files on Left | Folders on Right):${RESET}"
echo -e "${BLUE}-------------------------------------------------------------${RESET}"
printf "%-40s %-10s | %-40s %-10s\n" "Files" "Size" "Folders" "Size"
echo -e "${BLUE}-------------------------------------------------------------${RESET}"

# Get files and folders lists
files=$(find "$dir" -mindepth 1 -maxdepth 1 -type f -exec ls -lh {} + | awk '{printf "%-40s %-10s\n", $9, $5}' | sed "s|$dir/||")
folders=$(find "$dir" -mindepth 1 -maxdepth 1 -type d -exec du -sh {} + | awk '{printf "%-40s %-10s\n", $2, $1}' | sed "s|$dir/||")

# Merge files and folders into table format
paste <(echo "$files") <(echo "$folders") | column -t

echo -e "${BLUE}-------------------------------------------------------------${RESET}\n"

# Read Exclusions
read -rp "Enter exclusions (comma-separated): " ex
IFS=',' read -ra excl <<< "$ex"
excl_flags=()
for e in "${excl[@]}"; do
    excl_flags+=("--exclude=$(basename "$dir")/$e")
done

# Define Backup File Location
backup_dir="$HOME/backup"
backup_file="$backup_dir/backup_$(basename "$dir")_$(date +%Y%m%d_%H%M%S).tar.gz"
mkdir -p "$backup_dir"

# Start Backup Process
echo -e "\n${MAGENTA}Backup Compressing...${RESET}"
tar -czf "$backup_file" "${excl_flags[@]}" -C "$(dirname "$dir")" "$(basename "$dir")"

# Get Backup Size
backup_size=$(du -sh "$backup_file" | cut -f1)

# Display Backup Completion Message
echo -e "\n${GREEN}Backup Completed:${RESET} ${CYAN}$backup_file${RESET} ${YELLOW}(Size: $backup_size)${RESET}\n"
