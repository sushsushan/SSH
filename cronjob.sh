#!/bin/bash
# Advanced cPanel Cron Job Manager (Non-Root)
# Automates adding, listing, editing, and removing cron jobs with an easy-to-use interface

# Colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
CYAN='\e[36m'
RESET='\e[0m'

# Function to display current cron jobs
list_cron_jobs() {
    echo -e "${CYAN}\nCurrent Cron Jobs:${RESET}"
    crontab -l | nl || echo -e "${RED}No cron jobs found.${RESET}"
}

# Function to add a new cron job
add_cron_job() {
    echo -e "${YELLOW}\nChoose a schedule:${RESET}"
    echo "1. Every minute"
    echo "2. Every 5 minutes"
    echo "3. Every hour"
    echo "4. Every day"
    echo "5. Custom"
    read -p "Select an option (1-5): " schedule_option
    
    case $schedule_option in
        1) schedule="* * * * *" ;;
        2) schedule="*/5 * * * *" ;;
        3) schedule="0 * * * *" ;;
        4) schedule="0 0 * * *" ;;
        5) 
            echo -e "${CYAN}\nCustom Schedule Guide:${RESET}"
            echo "- Minute (0-59)"
            echo "- Hour (0-23)"
            echo "- Day of Month (1-31)"
            echo "- Month (1-12)"
            echo "- Day of Week (0-6, Sunday=0)"
            read -p "Enter custom cron schedule (e.g., '*/10 * * * *'): " schedule 
            ;;
        *) echo -e "${RED}Invalid option!${RESET}"; exit 1 ;;
    esac
    
    read -p "Enter the command to execute: " command
    (crontab -l; echo "$schedule $command") | crontab -
    echo -e "${GREEN}\nCron job added: '$schedule $command'.${RESET}"
}

# Function to delete a cron job
delete_cron_job() {
    list_cron_jobs
    read -p "Enter the job number to delete: " job_number
    crontab -l | sed "${job_number}d" | crontab -
    echo -e "${GREEN}\nCron job deleted.${RESET}"
}

# Function to edit a cron job
edit_cron_job() {
    list_cron_jobs
    read -p "Enter the job number to edit: " job_number
    temp_file=$(mktemp)
    crontab -l > "$temp_file"
    nano "$temp_file"
    crontab "$temp_file"
    rm "$temp_file"
    echo -e "${GREEN}\nCron job updated.${RESET}"
}

# Main Menu
while true; do
    echo -e "${CYAN}\n=== cPanel Cron Job Manager ===${RESET}"
    list_cron_jobs
    echo -e "${YELLOW}\nOptions:${RESET}"
    echo "1. Add a Cron Job"
    echo "2. Delete a Cron Job"
    echo "3. Edit a Cron Job"
    echo "4. Exit"
    read -p "Choose an option: " option
    
    case $option in
        1) add_cron_job ;;
        2) delete_cron_job ;;
        3) edit_cron_job ;;
        4) echo -e "${GREEN}\nExiting...${RESET}"; exit 0 ;;
        *) echo -e "${RED}\nInvalid option!${RESET}" ;;
    esac
done

