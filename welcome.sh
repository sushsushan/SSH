#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# Display main menu
echo -e "${CYAN}Welcome to the Mega Tool to automate your Linux tasks.${RESET}"
echo -e "${YELLOW}Here are the tools available to assist you:${RESET}\n"
echo -e "${GREEN}1:${RESET} cPanel"
echo -e "${GREEN}2:${RESET} Email"
echo -e "${GREEN}3:${RESET} Domain"
echo -e "${GREEN}4:${RESET} Database"
echo -e "${GREEN}5:${RESET} WordPress"
echo -e "${GREEN}6:${RESET} Backup Restore"
echo -e "${GREEN}7:${RESET} Optimization"
echo -e "${GREEN}9:${RESET} Other"
echo -e "${GREEN}0:${RESET} Home\n"

# Prompt user for input
while true; do
    read -p "${BLUE}Please enter your choice: ${RESET}" choice
    case $choice in
        1) script_url="https://raw.githubusercontent.com/sushsushan/SSH/main/1.sh" ;;
        2) script_url="https://raw.githubusercontent.com/sushsushan/SSH/main/2.sh" ;;
        3) script_url="https://raw.githubusercontent.com/sushsushan/SSH/main/3.sh" ;;
        4) script_url="https://raw.githubusercontent.com/sushsushan/SSH/main/4.sh" ;;
        5) script_url="https://raw.githubusercontent.com/sushsushan/SSH/main/5.sh" ;;
        6) script_url="https://raw.githubusercontent.com/sushsushan/SSH/main/6.sh" ;;
        7) script_url="https://raw.githubusercontent.com/sushsushan/SSH/main/7.sh" ;;
        9) script_url="https://raw.githubusercontent.com/sushsushan/SSH/main/9.sh" ;;
        0) script_url="https://raw.githubusercontent.com/sushsushan/SSH/main/home.sh" ;;
        *) echo -e "${RED}Invalid choice! Please select a valid option.${RESET}" && continue ;;
    esac
    
    # Execute the selected script
    echo -e "${CYAN}Fetching script...${RESET}"
    curl -s "$script_url" | bash
    break
done
