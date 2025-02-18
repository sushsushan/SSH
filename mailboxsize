#!/bin/bash

# Get current user and path info
USER=$(whoami)
PWD=$(pwd)

echo "============================================"
echo "   Mailbox Report - Generated on $(date)"
echo "   Current User: $USER"
echo "   Current Path: $PWD"
echo "============================================"
echo ""

# Set base mail directory
MAIL_DIR="/home/$USER/mail"

# Check if mail directory exists
if [ ! -d "$MAIL_DIR" ]; then
    echo "Error: Mail directory not found at $MAIL_DIR"
    exit 1
fi

# Scan domains and users
find "$MAIL_DIR" -mindepth 2 -maxdepth 2 -type d | while read -r dir; do
    DOMAIN=$(basename "$(dirname "$dir")")
    MAILBOX=$(basename "$dir")
    
    echo "--------------------------------------------"
    echo "📧 Email Address: $MAILBOX@$DOMAIN"
    echo "📂 Mailbox Path: $dir"
    echo "--------------------------------------------"

    # Define common mail folders
    FOLDERS=("cur" "new" "tmp" ".Sent" ".Spam" ".Trash" ".Drafts" ".Inbox")

    TOTAL_EMAILS=0
    TOTAL_SIZE=0

    # Loop through folders and get stats
    for FOLDER in "${FOLDERS[@]}"; do
        FOLDER_PATH="$dir/$FOLDER"
        if [ -d "$FOLDER_PATH" ]; then
            EMAIL_COUNT=$(find "$FOLDER_PATH" -type f | wc -l)
            FOLDER_SIZE=$(du -sh "$FOLDER_PATH" 2>/dev/null | cut -f1)
            
            TOTAL_EMAILS=$((TOTAL_EMAILS + EMAIL_COUNT))
            TOTAL_SIZE=$((TOTAL_SIZE + $(du -sb "$FOLDER_PATH" 2>/dev/null | awk '{print $1}') ))
            
            # Format output
            printf "📁 %-10s: %5d emails | Size: %s\n" "$(basename "$FOLDER")" "$EMAIL_COUNT" "$FOLDER_SIZE"
        fi
    done

    # Convert total size to human-readable format
    TOTAL_SIZE_HR=$(numfmt --to=iec-i --suffix=B $TOTAL_SIZE)

    echo "--------------------------------------------"
    echo "📊 Total Emails: $TOTAL_EMAILS"
    echo "💾 Total Mailbox Size: $TOTAL_SIZE_HR"
    echo "--------------------------------------------"
    echo ""
done
