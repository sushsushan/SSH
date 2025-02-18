#!/bin/bash

# Define color codes for better readability
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
BLUE="\e[34m"
CYAN="\e[36m"
BOLD="\e[1m"
RESET="\e[0m"

# Define function for creating backup
function create_backup() {
  clear
  echo -e "${BOLD}${CYAN}========================================="
  echo -e "       🗄️  Backup Script v1.0"
  echo -e "=========================================${RESET}\n"

  # Show current working directory and its disk usage
  pwd_size=$(du -sh --block-size=1G "$(pwd)" 2>/dev/null | awk '{print $1}')
  echo -e "${BOLD}${YELLOW}📂 Current Working Directory:${RESET} $(pwd) (${pwd_size} GiB)\n"

  # Prompt for document directory path
  read -p "🔹 Enter the path to the document directory: " document_dir

  # Validate document directory path
  if [ ! -d "$document_dir" ]; then
    echo -e "${RED}❌ Error: ${document_dir} is not a valid directory.${RESET}"
    exit 1
  fi

  # List files with correct sizes
  echo -e "\n${BOLD}${BLUE}📄 Files in ${document_dir}:${RESET}"
  find "$document_dir" -maxdepth 1 -type f | while read file; do
    size=$(stat --printf="%s" "$file" 2>/dev/null)
    if [ -n "$size" ]; then
      echo "  - $(basename "$file") ($(numfmt --to=iec-i --suffix=B "$size"))"
    fi
  done | sort

  # List folders with correct sizes
  echo -e "\n${BOLD}${BLUE}📁 Folders in ${document_dir}:${RESET}"
  find "$document_dir" -maxdepth 1 -type d ! -path "$document_dir" | while read dir; do
    size=$(du -sh "$dir" 2>/dev/null | awk '{print $1}')
    echo "  - $(basename "$dir") ($size)"
  done | sort

  # Show disk usage of the document directory
  doc_size=$(du -sh --block-size=1G "$document_dir" 2>/dev/null | awk '{print $1}')
  echo -e "\n${BOLD}${YELLOW}💾 Disk Usage of ${document_dir}:${RESET} ${doc_size} GiB\n"

  # Prompt for exclude file extensions, folders, or files
  read -p "🔹 Enter files, folders, or extensions to exclude (comma-separated, leave blank for none): " exclude_items

  # Create backup directory if it doesn't exist
  backup_dir="${HOME}/backup"
  mkdir -p "${backup_dir}"

  # Create backup filename based on current date and time
  backup_filename=$(date '+%Y%m%d_%H%M%S')"_backup.tar.gz"
  backup_path="${backup_dir}/${backup_filename}"

  # Construct the tar command with specified options
  if [ -z "$exclude_items" ]; then
    tar_cmd="tar -czhf ${backup_path} ${document_dir}"
  else
    exclude_options=$(echo "$exclude_items" | sed 's/,/ --exclude=/g' | sed 's/^/--exclude=/')
    tar_cmd="tar ${exclude_options} -czhf ${backup_path} ${document_dir}"
  fi

  # Execute the tar command
  echo -e "\n${BOLD}${CYAN}🛠️ Creating backup file...${RESET}"
  eval $tar_cmd

  # Check if the backup file was created successfully
  if [ -f "$backup_path" ]; then
    backup_size=$(du -sh "$backup_path" 2>/dev/null | awk '{print $1}')
    echo -e "${GREEN}✅ Backup successfully created at:${RESET} ${BOLD}${backup_path}${RESET} (${backup_size})\n"
  else
    echo -e "${RED}❌ Error creating backup file.${RESET}\n"
    exit 1
  fi

  # Prompt for another backup
  read -p "🔹 Would you like to take another backup? (y/n): " another_backup

  if [[ "${another_backup}" == "y" ]]; then
    create_backup
  else
    echo -e "${BOLD}${GREEN}📌 Backup process completed. Exiting script.${RESET}\n"
    exit 0
  fi
}

# Call the function to create a backup
create_backup
