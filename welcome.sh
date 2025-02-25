#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# Display header
echo -e "${CYAN}============================================================${RESET}"
echo -e "${CYAN}|            Welcome to the Mega Tool Automation           |${RESET}"
echo -e "${CYAN}============================================================${RESET}\n"
echo -e "${YELLOW}This tool helps you automate various Linux tasks effortlessly.${RESET}\n"

echo -e "${CYAN}------------------------------------------------------------${RESET}"
printf "| %-5s | %-35s |
" "${GREEN}Option${RESET}" "${GREEN}Feature${RESET}"
echo -e "${CYAN}------------------------------------------------------------${RESET}"
printf "| %-5s | %-35s |
" "1" "cPanel Management"
printf "| %-5s | %-35s |
" "2" "Email Services"
printf "| %-5s | %-35s |
" "3" "Domain Management"
printf "| %-5s | %-35s |
" "4" "Database Management"
printf "| %-5s | %-35s |
" "5" "WordPress Setup"
printf "| %-5s | %-35s |
" "6" "Backup & Restore"
printf "| %-5s | %-35s |
" "7" "System Optimization"
printf "| %-5s | %-35s |
" "8" "Security Enhancements"
printf "| %-5s | %-35s |
" "9" "Other Tools"
printf "| %-5s | %-35s |
" "0" "Return to Home"
echo -e "${CYAN}------------------------------------------------------------${RESET}\n"

# Prompt user for input
while true; do
    echo -ne "${BLUE}Please enter your choice: ${RESET}"
    read choice
    case $choice in
        1) script_url="https://raw.githubusercontent.com/sushsushan/SSH/main/1.sh" ;;
        2) script_url="https://raw.githubusercontent.com/sushsushan/SSH/main/2.sh" ;;
        3) script_url="https://raw.githubusercontent.com/sushsushan/SSH/main/3.sh" ;;
        4) script_url="https://raw.githubusercontent.com/sushsushan/SSH/main/4.sh" ;;
        5) script_url="https://raw.githubusercontent.com/sushsushan/SSH/main/5.sh" ;;
        6) script_url="https://raw.githubusercontent.com/sushsushan/SSH/main/6.sh" ;;
        7) script_url="https://raw.githubusercontent.com/sushsushan/SSH/main/7.sh" ;;
        8) script_url="https://raw.githubusercontent.com/sushsushan/SSH/main/8.sh" ;;
        9) script_url="https://raw.githubusercontent.com/sushsushan/SSH/main/9.sh" ;;
        0) script_url="https://raw.githubusercontent.com/sushsushan/SSH/main/home.sh" ;;
        *) echo -e "${RED}Invalid choice! Please select a valid option.${RESET}" && continue ;;
    esac
    
    # Execute the selected script
    echo -e "${CYAN}Fetching script...${RESET}"
    curl -s "$script_url" | bash
    break
done
