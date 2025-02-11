#!/bin/bash


# Confirm that the user is in the right directory
echo "You are currently in $(pwd)"
read -p "Is this the directory you want to modify? (y/n) " confirm
if [[ $confirm != [yY]* ]]; then
    echo "Aborting"
    exit 1
fi


# Check for .htaccess file
if [[ -e .htaccess ]]; then
    read -p "There is already a .htaccess file in this directory. Do you want to modify it? (y/n) " modify
    if [[ $modify == [yY]* ]]; then
        # TODO: modify .htaccess file
        echo "Modifying existing .htaccess file"
    else
        read -p "Do you want to rename the existing .htaccess file and create a new one? (y/n) " rename
        if [[ $rename == [yY]* ]]; then
            timestamp=$(date +"%Y%m%d_%H%M%S")
            mv .htaccess .htaccess_$timestamp
            echo "Renamed existing .htaccess file to .htaccess_$timestamp"
        fi
    fi
fi


# Choose what rules to add to .htaccess file
echo "What rules do you want to add to the .htaccess file?"
echo "1. Force HTTPS"
echo "2. Redirect non-www to www"
echo "3. Redirect www to non-www"
echo "4. Redirect non-www to www with HTTPS"
echo "5. Do not add any rules"
read -p "Enter a number [1-5]: " choice


# Write .htaccess rules based on user's choice
case $choice in
    1) echo "RewriteEngine On" >> .htaccess
       echo "RewriteCond %{HTTPS} off" >> .htaccess
       echo "RewriteRule (.*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]" >> .htaccess
       echo "Added force HTTPS rule to .htaccess file";;
    2) echo "RewriteEngine On" >> .htaccess
       echo "RewriteCond %{HTTP_HOST} !^www\." >> .htaccess
       echo "RewriteRule (.*) http://www.%{HTTP_HOST}%{REQUEST_URI} [R=301,L]" >> .htaccess
       echo "Added redirect non-www to www rule to .htaccess file";;
    3) echo "RewriteEngine On" >> .htaccess
       echo "RewriteCond %{HTTP_HOST} ^www\.(.*)$" >> .htaccess
       echo "RewriteRule (.*) http://%1%{REQUEST_URI} [R=301,L]" >> .htaccess
       echo "Added redirect www to non-www rule to .htaccess file";;
    4) echo "RewriteEngine On" >> .htaccess
       echo "RewriteCond %{HTTP_HOST} !^www\." >> .htaccess
       echo "RewriteCond %{HTTPS} off" >> .htaccess
       echo "RewriteRule (.*) https://www.%{HTTP_HOST}%{REQUEST_URI} [R=301,L]" >> .htaccess
       echo "Added redirect non-www to www with HTTPS rule to .htaccess file";;
    5) echo "No rules added to .htaccess file";;
    *) echo "Invalid choice";;
esac


# Fix file permissions
chmod 644 .htaccess
echo "Fixed permissions on .htaccess file"


echo "Done"
