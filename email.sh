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
    uapi Email list_pops | grep -q "email: $username"
}


# Function to create a new email
create_email() {
    read -p "Enter the username for the new email: " username


    if email_exists "$username"; then
        echo "Email already exists. Please choose a different username."
        return
    fi


    password=$(< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c12)  # Generate a random password


    uapi Email add_pop email="$username" password="$password"


    echo "New Email created successfully:"
    echo "Username: $username"
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
