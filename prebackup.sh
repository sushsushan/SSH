#!/bin/bash

# Function to display a progress animation
progress_animation() {
    local delay=0.1
    local spin='|/-\'
    while kill -0 "$1" 2>/dev/null; do
        for i in {0..3}; do
            echo -ne "\rBackup in progress... ${spin:$i:1} "
            sleep $delay
        done
    done
    echo -ne "\rBackup completed!      \n"
}

# Welcome Message
echo -e "\n\033[1;32mWelcome to the Backup Tool\033[0m"
read -rp "Enter the directory path to backup: " dir

dir="$(realpath -m "$dir")"

# Validate directory
if [[ ! -d "$dir" ]]; then
    echo -e "\033[1;31mError: Invalid directory!\033[0m"
    exit 1
fi

# Display disk usage
clear
echo -e "\n\033[1;34mDisk Usage for: \033[1;36m$dir\033[0m"
du -sh "$dir"

echo -e "\n\033[1;33mListing Files and Folders:\033[0m"
find "$dir" -mindepth 1 -maxdepth 1 -exec du -sh {} + | sort | awk '{printf "  \033[1;36m%-40s\033[0m (\033[1;33m%s\033[0m)\n", $2, $1}'

# Select compression format
echo -e "\nSelect a compression format:\n1) .tar.gz\n2) .zip\n3) .tar.xz"
read -rp "Enter choice (1/2/3): " choice

case $choice in
    1) ext="tar.gz"; cmd="tar -czf";;
    2) ext="zip"; cmd="zip -r";;
    3) ext="tar.xz"; cmd="tar -cJf";;
    *) echo "Invalid choice!"; exit 1;;
esac

# Ask for exclusions
read -rp "Enter files/folders to exclude (comma-separated, or leave blank): " ex
IFS=',' read -ra excl <<< "$ex"
excl_flags=()

for e in "${excl[@]}"; do
    [[ -n "$e" ]] && excl_flags+=("--exclude=$e")
done

# Define backup path
backup_dir="$HOME/backup"
mkdir -p "$backup_dir"
backup_file="$backup_dir/backup_$(basename "$dir")_$(date +%Y%m%d_%H%M%S).$ext"

# Start backup with progress animation
clear
echo -e "\n\033[1;35mStarting Backup...\033[0m"
if [[ "$ext" == "zip" ]]; then
    zip -r "$backup_file" "$dir" "${excl_flags[@]}" & progress_animation $!
else
    tar ${cmd} "$backup_file" "${excl_flags[@]}" -C "$(dirname "$dir")" "$(basename "$dir")" & progress_animation $!
fi

# Display backup details
echo -e "\n\033[1;32mBackup Completed:\033[0m \033[1;36m$backup_file\033[0m"
du -sh "$backup_file"

exit 0
