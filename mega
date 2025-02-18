#!/bin/bash
export TZ="Asia/Kolkata"
clear

# Define color variables
RED='\e[1;31m'
GREEN='\e[1;32m'
YELLOW='\e[1;33m'
BLUE='\e[1;34m'
MAGENTA='\e[1;35m'
CYAN='\e[1;36m'
WHITE='\e[1;37m'
BOLD='\e[1m'
RESET='\e[0m'

# 3D Header with Colors
echo -e "${CYAN}                                                                                 ${RESET}"
echo -e "${CYAN}   ██████╗ ██╗   ██╗ ██████╗ ███████╗████████╗     ████████╗ ██████╗  ██████╗ ██╗     ${RESET}"
echo -e "${CYAN}   ██╔══██╗██║   ██║██╔════╝ ██╔════╝╚══██╔══╝     ╚══██╔══╝██╔═══██╗██╔═══██╗██║     ${RESET}"
echo -e "${CYAN}   ██████╔╝██║   ██║██║  ███╗███████╗   ██║          ██║   ██║   ██║██║   ██║██║     ${RESET}"
echo -e "${CYAN}   ██╔═══╝ ██║   ██║██║   ██║╚════██║   ██║          ██║   ██║   ██║██║   ██║██║     ${RESET}"
echo -e "${CYAN}   ██║     ╚██████╔╝╚██████╔╝███████║   ██║          ██║   ╚██████╔╝╚██████╔╝███████╗${RESET}"
echo -e "${CYAN}   ╚═╝      ╚═════╝  ╚═════╝ ╚══════╝   ╚═╝          ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝${RESET}"
echo ""

# Date and Time in Center
DATE_INFO="$(date '+%A, %d %B %Y | %I:%M:%S %p | %Z')"
printf "%*s\n" $((($(tput cols) + ${#DATE_INFO}) / 2)) "${YELLOW}${DATE_INFO}${RESET}"

# OS Information
OS_NAME=$(cat /etc/os-release | grep -E '^PRETTY_NAME' | cut -d= -f2 | tr -d '"')
echo -e "${BLUE}═════════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${WHITE}            🚀 System Information: ${YELLOW}${OS_NAME} ${RESET}"
echo -e "${BLUE}═════════════════════════════════════════════════════════════════════════════════${RESET}"

# System Details
echo -e "${GREEN}🖥️  PHP Version:             ${WHITE}$(php -v | awk '/^PHP/ {print $2}' | head -n 1 || echo "Not available")${RESET}"
echo -e "${GREEN}🐍 Python Version:          ${WHITE}$(python -V 2>&1 | awk '{print $2}' || echo "Not available")${RESET}"
echo -e "${GREEN}🛢️  MySQL Version:           ${WHITE}$(mysql -V | awk '{print $5}' | sed 's/,//')${RESET}"
echo -e "${GREEN}📦 cPanel Version:          ${WHITE}$(cat /usr/local/cpanel/version || echo "Not available")${RESET}"

# Check Compiler Group Membership
if groups $(whoami) | grep -q '\bcompiler\b'; then
    compiler_status="${GREEN}✅ YES${RESET}"
else
    compiler_status="${RED}❌ NO${RESET}"
fi
echo -e "${GREEN}🔧 Compiler Group:          ${compiler_status}"

# More Server Info
CPU_MODEL=$(lscpu | grep "Model name" | cut -d: -f2 | xargs)
RAM_USAGE=$(free -h | awk '/^Mem:/ {print $3 "/" $2}')
ACTIVE_USERS=$(who | wc -l)

echo -e "${GREEN}⚙️  CPU Model:               ${WHITE}${CPU_MODEL}${RESET}"
echo -e "${GREEN}💾 RAM Usage:              ${WHITE}${RAM_USAGE}${RESET}"
echo -e "${GREEN}👥 Active Users:           ${WHITE}${ACTIVE_USERS}${RESET}"

# Home Directory Info - Detecting Correct Home Partition
USER_HOME=$(eval echo ~$USER)
HOME_PARTITION=$(df -h "$USER_HOME" | awk 'NR==2 {print $1}')
HOME_FREE_SPACE=$(df -h "$USER_HOME" | awk 'NR==2 {print $4}')

echo -e "${GREEN}🏠 Home Partition:          ${WHITE}${HOME_PARTITION}${RESET}"
echo -e "${GREEN}📂 Free Space in Home:      ${WHITE}${HOME_FREE_SPACE}${RESET}"
echo -e "${GREEN}📌 Home Directory Path:     ${WHITE}${USER_HOME}${RESET}"

# Exit Message
echo -e "${MAGENTA}═════════════════════════════════════════════════════════════════════════════════${RESET}"
echo -e "${YELLOW}  📩 For more information, contact Sushan  |  Author: Sushan                     ${RESET}"
echo -e "${YELLOW}  🎯 Role: Tech Tier3 Support Engineer   |   Email: sushan@sush.com              ${RESET}"
echo -e "${MAGENTA}═════════════════════════════════════════════════════════════════════════════════${RESET}"

# Prevent Ctrl+C (SIGINT) from terminating the script
trap '' SIGINT

# Function to prompt user for valid input
get_valid_input() {
  while true; do
    echo -e "${CYAN}🔹 Would you like to proceed to the bash script? (y/n): ${RESET}"
    read -p "" choice
    case "$choice" in
      y|Y) 
        bash <(curl -sS https://raw.githubusercontent.com/sushsushan/SSH/refs/heads/main/welcome.sh)
        break
        ;;
      n|N) 
        messages=("Goodbye! 🚀" "Have a nice day! 🎉" "Take care! 😊" "See you later! 👋" "Have a good one! 🌟" "Adios! 💨" "Catch you later! ⚡" "Until next time! 🔥")
        rand=$((RANDOM % ${#messages[@]}))  
        echo -e "${RED}${messages[$rand]}${RESET}"
        break
        ;;
      *) 
        echo -e "${RED}❌ Invalid input! Please enter 'y' for Yes or 'n' for No.${RESET}"
        ;;
    esac
  done
}

# Call the function to get user input
get_valid_input
