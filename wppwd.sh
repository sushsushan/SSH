#!/bin/bash


# Ask for confirmation of correct directory
echo "Are you in the correct directory? (y/n)"
read confirm_dir
if [ "$confirm_dir" != "y" ]; then
  echo "Exiting script"
  exit 1
fi


# Extract database info from wp-config.php
db_name=$(grep DB_NAME wp-config.php | cut -d "'" -f 4)
db_user=$(grep DB_USER wp-config.php | cut -d "'" -f 4)
db_pass=$(grep DB_PASSWORD wp-config.php | cut -d "'" -f 4)
db_host=$(grep DB_HOST wp-config.php | cut -d "'" -f 4)


# List admin users and prompt for selection
echo "Select a user to reset password for:"
wp user list --role=administrator --fields=user_login
read user_login


# Validate user input
if ! wp user list --role=administrator --fields=user_login | grep -q "^$user_login$"; then
  echo "Invalid user selected. Exiting script."
  exit 1
fi


# Prompt for password generation method
echo "Do you want to reset the password, or create a temporary session?"
echo "Enter 'reset' or 'session':"
read choice


if [ "$choice" = "reset" ]; then
  echo "Do you want to use a system-generated password or provide your own?"
  echo "Enter 'auto' or 'manual':"
  read password_method


  # Generate password
  if [ "$password_method" = "auto" ]; then
    new_password=$(openssl rand -base64 12)
  else
    echo "Enter new password:"
    read new_password
  fi


  # Update user password
  wp user update "$user_login" --user_pass="$new_password"


  # Output confirmation and login information
  echo "Password for user $user_login has been updated."
  echo "Login URL: $(wp option get siteurl)/wp-login.php"
  echo "Username: $user_login"
  echo "Password: $new_password"


elif [ "$choice" = "session" ]; then
  temporary_password=$(openssl rand -base64 12)


  # Set user's temporary password
  wp user update "$user_login" --user_pass="$temporary_password"


  # Output confirmation and login information
  echo "Temporary session for user $user_login has been created."
  echo "Your temporary password is: $temporary_password"
  echo "This password will expire in 30 minutes."
  echo "Login URL: $(wp option get siteurl)/wp-login.php"
  echo "Username: $user_login"


  # Wait for 30 minutes
  sleep 1800


  # Revert user's password
  wp user update "$user_login" --user_pass="$db_pass"


  # Output confirmation
  echo "Temporary session for user $user_login has expired."
  echo "Password has been reverted to the original password."
else
  echo "Invalid choice selected. Exiting script."
  exit 1
fi
