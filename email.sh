#!/bin/bash

# Function to clear the screen
clear_screen() {
    clear
}

# Function to get the server hostname
get_server_hostname() {
    hostname
}

# Function to list current emails
list_emails() {
    uapi Email list_pops | grep "email:"
}

# Function to check if an email already exists
email_exists() {
    local username="$1"
    local domain="$2"
    uapi Email list_pops | grep -q "email: $username@$domain"
}

# Function to create a new email
create_email() {
    read -p "Enter the domain for the new email (e.g., example.com): " domain
    read -p "Enter the username for the new email: " username

    # Check if the domain is valid
    if [[ ! "$domain" =~ ^[a-zA-Z0-9.-]+$ ]]; then
        echo "Invalid domain. Please enter a valid domain."
        return
    fi

    # Check if the email already exists
    if email_exists "$username" "$domain"; then
        echo "Email already exists. Please choose a different username."
        return
    fi

    password=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c12)  # Generate a random password

    # Create the email with the specified domain
    uapi Email add_pop email="$username@$domain" password="$password"

    echo "New Email created successfully:"
    echo "Username: $username@$domain"
    echo "Password: $password"
    echo "Login Link: https://$(get_server_hostname):2096/"
}

# Main script
while true; do
    clear_screen

    echo "Current Email List:"
    list_emails

    create_email

    read -p "Do you want to create another email? (yes/no): " answer
    case $answer in
        [Nn]* ) break;;
    esac
done
