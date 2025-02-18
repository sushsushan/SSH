#!/bin/bash

# Get the current directory
current_dir=$(pwd)

# Show all WordPress paths under /home/user/
echo "Current path: $current_dir"
echo "Searching for WordPress installations in /home/user/"

# List directories under /home/user/ that contain wp-config.php
wp_paths=$(find /home/user/ -type f -name wp-config.php)

# Check if wp-config.php exists in any directory
if [ -z "$wp_paths" ]; then
  echo "No WordPress installation found. Please confirm the installation is valid."
  exit 1
fi

# Show all WordPress paths
echo "WordPress installations found at the following paths:"
echo "$wp_paths"

# Ask the user if they are in the correct directory
echo "Are you in the correct WordPress directory? (y/n)"
read confirm_dir

if [ "$confirm_dir" != "y" ]; then
  echo "Please provide the correct path to your WordPress installation:"
  read custom_path
  if [ ! -f "$custom_path/wp-config.php" ]; then
    echo "Invalid path. No wp-config.php found at the specified location. Exiting script."
    exit 1
  fi
  cd "$custom_path" || exit 1
else
  # Ensure we are in the correct directory
  cd "$(dirname "$wp_paths")" || exit 1
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
