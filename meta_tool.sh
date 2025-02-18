#!/bin/bash
export TZ="Asia/Kolkata"
clear

echo '																			   '
echo '	███╗   ███╗███████╗ ██████╗  █████╗     ████████╗ ██████╗  ██████╗ ██╗     '
echo '	████╗ ████║██╔════╝██╔════╝ ██╔══██╗    ╚══██╔══╝██╔═══██╗██╔═══██╗██║     '
echo '	██╔████╔██║█████╗  ██║  ███╗███████║       ██║   ██║   ██║██║   ██║██║     '
echo '	██║╚██╔╝██║██╔══╝  ██║   ██║██╔══██║       ██║   ██║   ██║██║   ██║██║     '
echo '	██║ ╚═╝ ██║███████╗╚██████╔╝██║  ██║       ██║   ╚██████╔╝╚██████╔╝███████╗'
echo '	╚═╝     ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝       ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝'

echo "$(date '+%A, %d %B %Y %I:%M:%S %p %Z')" | awk '{ printf("%60s", $0) }'
 
echo ""
echo "  ╔══════════════════════════════════════════════════════════════════════╗"
echo "  ║                  System Information :CentOS Version                  ║"
echo "  ╚══════════════════════════════════════════════════════════════════════╝"
echo ""

echo "PHP Version:             $(php -v | awk '/^PHP/ {print $2}' | head -n 1 || echo "Not available")"
echo "Python Version:          $(python -V 2>&1 | awk '{print $2}' || echo "Not available")"
echo "MySQL Version:           $(mysql -V | awk '{print $5}' | sed 's/,//')"
echo "cPanel Version:          $(cat /usr/local/cpanel/version || echo "Not available")"
echo "cPanel Build Number:     $(/usr/local/cpanel/cpanel -V | awk '/build/ {print $NF}' || echo "Not available")"
compiler_group=$(groups $(id -un) | grep -q '\bcompiler\b' && echo "YES" || echo "NO")
echo "Compiler Group:          $compiler_group"

echo "TLS Version:             $(openssl ciphers -v | awk '{print $2}' | sort | uniq | tail -1 || echo "Not available")"
echo "Apache Version:          $([[ -f /etc/cpanel/ea4/is_ea4 ]] && echo "EA4" || echo "EA3")"
last_boot=$(last | grep boot | head -1 | awk '{print $5,$6,$7,$8,$9}')
if [ -n "$last_boot" ]; then
    echo "Last Boot Time:          $last_boot"
fi
echo "Home Directory Size:     $(du -hs ~ 2>/dev/null | awk '{print $1}' | sed 's/G$/GB/' | sed 's/M$/MB/' || echo "Not available")"
echo "Home Directory Path:     $(echo ~)"
 
echo '       ________________________________________________________'
echo '      /                                                        \'
echo '     |   For more information, please contact Sushan           |'
echo '     |                  Author: Sushan                         |'
echo '     |              Role: Tech Tier3 Support Engineer          |'
echo '     |                 Email: sushan@sush.com                  |'
echo '      \           ღ(¯`◕‿◕´¯)    c(◕ヮ◕n )     ¯´◕‿◕`¯(ღ         /'
echo '       --------------------------------------------------------'
echo '             \                                        /'
echo '              \       ______             _           /'
echo '               \     / _____)           | |         /'
echo '                \   ( (____   _   _  ___| |__      /'
echo '                 \   \_____ \| | | |/___|  _ \    /'
echo '                  \   _____) | |_| |___ | | | |  /'
echo '                   \ (______/|____/(___/|_| |_| /'
echo '                    \                          /'
echo '                    ----------------------------'
echo '                           \          .  '
echo '                            \        /   .'
echo '                             \      /   /'
echo '                              \    /   /'
echo '                               \  /   /'
echo '                                \/___/'
echo "" 

# Prevent Ctrl+C (SIGINT) from terminating the script
trap '' SIGINT

# Function to prompt user for valid input
get_valid_input() {
  while true; do
    read -p "Would you like to proceed to the bash script? (y/n): " choice
    case "$choice" in
      y|Y) 
        bash <(curl -sS https://raw.githubusercontent.com/sushsushan/SSH/refs/heads/main/welcome.sh)
        break
        ;;
      n|N) 
        messages=("Goodbye!" "Have a nice day!" "Take care!" "See you later!" "Have a good one!" "Adios!" "Catch you later!" "Until next time!")
        rand=$((RANDOM % ${#messages[@]}))  
        echo "${messages[$rand]}"
        break
        ;;
      *) 
        echo "Invalid input! Please enter 'y' for Yes or 'n' for No."
        ;;
    esac
  done
}

# Call the function to get user input
get_valid_input
