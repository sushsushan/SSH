#!/bin/bash

# Set the timezone to IST
export TZ="Asia/Kolkata"

# Clear the screen
clear

# Display banner
echo ""
echo "  ███████╗██╗   ██╗███████╗██╗  ██╗ █████╗ ███╗   ██╗"
echo "  ██╔════╝██║   ██║██╔════╝██║  ██║██╔══██╗████╗  ██║"
echo "  █████╗  ██║   ██║███████╗███████║███████║██╔██╗ ██║"
echo "  ██╔══╝  ██║   ██║╚════██║██╔══██║██╔══██║██║╚██╗██║"
echo "  ██║     ╚██████╔╝███████║██║  ██║██║  ██║██║ ╚████║"
echo "  ╚═╝      ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝"
echo ""

# Display current date and time (IST)
printf "%s%60s\n" "Current Time: " "$(date '+%A, %d %B %Y %I:%M:%S %p %Z')"

echo ""
echo "  ╔══════════════════════════════════════════════════════════════╗"
echo "  ║                  System Information (CentOS)                 ║"
echo "  ╚══════════════════════════════════════════════════════════════╝"
echo ""

echo -e "  🟢 PHP Version:          $(php -v 2>/dev/null | awk '/^PHP/ {print $2}' | head -n 1 || echo "Not installed")"
echo -e "  🟡 Python Version:       $(python3 -V 2>&1 | awk '{print $2}' || echo "Not installed")"
echo -e "  🔵 MySQL Version:        $(mysql -V 2>/dev/null | awk '{print $5}' | sed 's/,//')"
echo -e "  🟣 cPanel Version:       $(cat /usr/local/cpanel/version 2>/dev/null || echo "Not installed")"
echo -e "  🟠 cPanel Build:         $(/usr/local/cpanel/cpanel -V 2>/dev/null | awk '/build/ {print $NF}' || echo "Not available")"

# Check if user is part of 'compiler' group
if groups $(whoami) | grep -q '\bcompiler\b'; then
    compiler_group="✅ YES"
else
    compiler_group="❌ NO"
fi
echo -e "  🛠  Compiler Group:      $compiler_group"

echo -e "  🔑 TLS Version:          $(openssl ciphers -v 2>/dev/null | awk '{print $2}' | sort | uniq | tail -1 || echo "Not available")"
echo -e "  🌐 Apache Version:       $([[ -f /etc/cpanel/ea4/is_ea4 ]] && echo "EA4" || echo "EA3")"

# Last boot time
last_boot=$(last reboot | head -1 | awk '{print $5,$6,$7,$8}')
echo -e "  🔄 Last Boot Time:      ${last_boot:-"Unknown"}"

# Home directory size
home_size=$(du -hs ~ 2>/dev/null | awk '{print $1}' | sed 's/G$/GB/' | sed 's/M$/MB/')
echo -e "  🏠 Home Dir Size:       ${home_size:-"Unknown"}"
echo -e "  📂 Home Dir Path:       $(echo ~)"

echo ""
echo "  ╔════════════════════════════════════════════════════════════════╗"
echo "  ║                 Contact Information & Author                   ║"
echo "  ╚════════════════════════════════════════════════════════════════╝"
echo ""
echo "  📝 Author:       Sushan"
echo "  💼 Role:        Tech Tier3 Support Engineer"
echo "  ✉️  Email:       sushan@sush.com"
echo ""

# ASCII Art
echo '     ___________________________________________________________'
echo '    /                                                           \'
echo '   |   🎯 For more info, please contact Sushan                 |'
echo '   |   📩 Email: sushan@sush.com                               |'
echo '    \       ღ(¯`◕‿◕´¯)    c(◕ヮ◕n )     ¯´◕‿◕`¯(ღ        /'
echo '     -----------------------------------------------------------'
echo ""

# User Prompt
read -p "Would you like to proceed to the next bash script? (y/n): " choice
if [[ $choice == "y" || $choice == "Y" ]]; then
    bash <(curl -s https://raw.githubusercontent.com/sushsushan/SSH/main/hits.sh)
else
    messages=("Goodbye!" "Have a nice day!" "Take care!" "See you later!" "Have a good one!" "Adios!" "Catch you later!" "Until next time!")
    echo " ${messages[$RANDOM % ${#messages[@]}]}"
fi
