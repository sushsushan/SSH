#!/bin/bash
# Advanced cPanel Cron Job Manager (Non-Root)
# Automates adding, listing, editing, and removing cron jobs with a user-friendly interface

# Colors
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
CYAN='\e[36m'
MAGENTA='\e[35m'
WHITE='\e[97m'
RESET='\e[0m'

# Function to display a table of current cron jobs
list_cron_jobs() {
    echo -e "${CYAN}\n================================="
    echo -e "      Current Cron Jobs      "
    echo -e "=================================${RESET}"
    crontab -l | awk '{print NR" | "$0}' | column -t -s '|'
    if [ $? -ne 0 ]; then
        echo -e "${RED}No cron jobs found.${RESET}"
    fi
}

# Function to add a new cron job
add_cron_job() {
    echo -e "${MAGENTA}\n=== Add a New Cron Job ===${RESET}"
    echo -e "${YELLOW}\nChoose a schedule:${RESET}"
    echo -e "${WHITE}1. Every minute\n2. Every 5 minutes\n3. Every hour\n4. Every day\n5. Custom${RESET}"
    read -p "Select an option (1-5): " schedule_option
    
    case $schedule_option in
        1) schedule="* * * * *" ;;
        2) schedule="*/5 * * * *" ;;
        3) schedule="0 * * * *" ;;
        4) schedule="0 0 * * *" ;;
        5) 
            echo -e "${CYAN}\nCustom Schedule Guide:${RESET}"
            echo "Minute (0-59), Hour (0-23), Day of Month (1-31), Month (1-12), Day of Week (0-6, Sunday=0)"
            read -p "Enter custom cron schedule (e.g., '*/10 * * * *'): " schedule 
            ;;
        *) echo -e "${RED}Invalid option!${RESET}"; return ;;
    esac
    
    read -p "Enter the command to execute: " command
    (crontab -l; echo "$schedule $command") | crontab -
    echo -e "${GREEN}\nCron job added successfully!${RESET}"
}

# Function to delete a cron job
delete_cron_job() {
    list_cron_jobs
    read -p "Enter the job number to delete: " job_number
    crontab -l | sed "${job_number}d" | crontab -
    echo -e "${GREEN}\nCron job deleted successfully!${RESET}"
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
    echo -e "${GREEN}\nCron job updated successfully!${RESET}"
}

# Function to display tutorial
tutorial() {
    echo -e "${CYAN}\n================================="
    echo -e "       Cron Job Tutorial       "
    echo -e "=================================${RESET}"
    echo -e "\n${WHITE}A cron job is a scheduled task that runs automatically at specified times.${RESET}"
    echo -e "\n${YELLOW}Cron Syntax:${RESET}"
    echo -e "${WHITE}* * * * * command${RESET}  (Minute, Hour, Day of Month, Month, Day of Week)"
    echo -e "\n${GREEN}Examples:${RESET}"
    echo -e "- Run every minute: ${WHITE}* * * * * echo 'Hello' >> /tmp/hello.log${RESET}"
    echo -e "- Run every day at midnight: ${WHITE}0 0 * * * /path/to/script.sh${RESET}"
    echo -e "- Run every Monday at 3 PM: ${WHITE}0 15 * * 1 /path/to/script.sh${RESET}"
    echo -e "\n${CYAN}How This Tool Works:${RESET}"
    echo -e "1. ${WHITE}List Current Cron Jobs:${RESET} Displays existing cron jobs."
    echo -e "2. ${WHITE}Add Cron Job:${RESET} Provides an easy way to schedule tasks without knowing cron syntax."
    echo -e "3. ${WHITE}Delete Cron Job:${RESET} Removes an existing cron job by selecting its number."
    echo -e "4. ${WHITE}Edit Cron Job:${RESET} Opens a text editor to modify an existing cron job."
    echo -e "5. ${WHITE}Exit:${RESET} Quits the tool."
}

# Main Menu
while true; do
    echo -e "${CYAN}\n====================================="
    echo -e "     cPanel Cron Job Manager      "
    echo -e "=====================================${RESET}"
    list_cron_jobs
    echo -e "${YELLOW}\nOptions:${RESET}"
    echo -e "${WHITE}1. Add a Cron Job\n2. Delete a Cron Job\n3. Edit a Cron Job\n4. Tutorial\n5. Exit${RESET}"
    read -p "Choose an option: " option
    
    case $option in
        1) add_cron_job ;;
        2) delete_cron_job ;;
        3) edit_cron_job ;;
        4) tutorial ;;
        5) echo -e "${GREEN}\nExiting...${RESET}"; exit 0 ;;
        *) echo -e "${RED}\nInvalid option!${RESET}" ;;
    esac
done
