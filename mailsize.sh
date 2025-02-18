#!/bin/bash

# Get current user and path info
USER=$(whoami)
PWD=$(pwd)

echo "Current User: $USER"
echo "Current Path: $PWD"

# Scan mail directory
MAIL_DIR="/home/$USER/mail"

# Loop through domains and users
find "$MAIL_DIR" -mindepth 2 -maxdepth 2 -type d | while read -r dir; do
    DOMAIN=$(basename "$(dirname "$dir")")
    MAILBOX=$(basename "$dir")
    
    # Count emails
    EMAIL_COUNT=$(find "$dir" -type f | wc -l)
    
    # Calculate size
    MAILBOX_SIZE=$(du -sh "$dir" | cut -f1)
    
    # Print results
    echo "---------------------------------"
    echo "Email Address: $MAILBOX@$DOMAIN"
    echo "Number of Emails: $EMAIL_COUNT"
    echo "Mailbox Size: $MAILBOX_SIZE"
    echo "Path: $dir"
    echo "---------------------------------"
done
