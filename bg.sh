#!/bin/bash


clear


# define function for creating backup
function create_backup() {
  # show current working directory and its disk usage
  pwd_size=$(du -sh --block-size=1G "$(pwd)" 2>/dev/null | awk '{print $1}')
  echo "Current working directory: $(pwd) (${pwd_size}GiB)"


  # prompt for document directory path
  read -p "Enter the path to the document directory: " document_dir


  # validate document directory path
  if [ ! -d "$document_dir" ]; then
    echo "Error: ${document_dir} is not a valid directory."
    exit 1
  fi


  clear


  # list files and folders in document directory
  echo -e "\nFiles in ${document_dir}:"
  printf "%-40s %-10s\n" "Filename" "Size"
  printf "%-40s %-10s\n" "------------------------" "----------"
  find "$document_dir" -maxdepth 1 -type f -printf "%-40f %-10sB\n" | sort
  echo -e "\nFolders in ${document_dir}:"
  printf "%-40s %-10s\n" "Folder" "Size"
  printf "%-40s %-10s\n" "------------------------" "----------"
  find "$document_dir" -maxdepth 1 -type d ! -path "$document_dir" -printf "%-40f %-10sB\n" | sort


  # show disk usage of document directory
  doc_size=$(du -sh --block-size=1G "$document_dir" 2>/dev/null | awk '{print $1}')
  echo "Disk usage of ${document_dir}: ${doc_size}GiB"


  # prompt for exclude file extensions, folders, or files
  read -p "Enter files, folders, or extensions to exclude (comma-separated, leave blank for none): " exclude_items


  clear


  # create backup directory if it doesn't exist
  backup_dir="${HOME}/backup"
  mkdir -p "${backup_dir}"


  # create backup filename based on current date and time
  backup_filename=$(date '+%Y%m%d_%H%M%S')"_backup.tar.gz"
  backup_path="${backup_dir}/${backup_filename}"


  # construct the tar command with specified options
  if [ -z "$exclude_items" ]; then
    tar_cmd="tar -czhf ${backup_path} ${document_dir}"
  else
    exclude_options=$(echo "$exclude_items" | sed 's/,/ --exclude=/g' | sed 's/^/--exclude=/')
    tar_cmd="tar ${exclude_options} -czhf ${backup_path} ${document_dir}"
  fi


  # execute the tar command
  echo "Creating backup file ${backup_filename}..."
  tar_output=$(eval $tar_cmd 2>&1)


  # check if backup file was created successfully
  if [ -f "$backup_path" ]; then
    backup_size=$(du -sh "$backup_path" 2>/dev/null | awk '{print $1}')
    clear
    echo -e "\n╭───────────────────────────────────────────────────────╮"
    echo "│ Backup file created successfully!                                                                       │"
    echo "├───────────────────────────────────────────────────────┤"
    echo "│ Filename: $(basename $backup_path)                      │"
    echo "│ Path:     $backup_path                                         │"
    echo "│ Size:     $backup_size                                   │"
    echo "╰───────────────────────────────────────────────────────╯"
  else
    echo "Error creating backup file."
    echo "Tar output: $tar_output"
    exit 1
  fi


  # prompt for another backup
  read -p "Would you like to take another backup? (y/n): " another_backup
  if [[ "${another_backup}" == "y" ]]; then
    # execute the backup process again
    create_backup
  else
    clear
    echo "Exiting backup script."
    exit 0
  fi
}


# call the function to create backup
create_backup
