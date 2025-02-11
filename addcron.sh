#!/bin/bash


echo "Welcome to the cron job creator!"
echo "This script will help you create new cron jobs."
echo "Please answer the following questions."


while true; do
    # Prompt for the command to run
    read -p "Enter the command to run (e.g. /path/to/command): " command


    # Prompt for the schedule and validate it
    while true; do
        read -p "Enter the schedule for the cron job (e.g. * * * * * for every minute): " schedule
        if [[ "$schedule" =~ ^(\*|[0-5]?[0-9])\ (\*|[01]?[0-9]|2[0-3])\ (\*|[01]?[0-9]|2[0-3])\ (\*|[1-9]|[1-2][0-9]|3[0-1])\ (\*|[1-9]|1[0-2])$ ]]; then
            break
        else
            echo "Invalid schedule. Please enter a valid cron schedule."
        fi
    done


    # Add the cron job and confirm that it was created successfully
    (crontab -l ; echo "$schedule $command") | crontab -
    if [[ "$?" -eq 0 ]]; then
        echo "Cron job created successfully."
    else
        echo "Error creating cron job."
    fi


    # Prompt to add another cron job or exit
    read -p "Do you want to add another cron job? (y/n): " answer
    if [[ "$answer" =~ ^[Nn]$ ]]; then
        break
    fi
done


# Redirect to cron.sh
echo "Redirecting to cron.sh"
./cron.sh

