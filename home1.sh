#!/bin/bash

export TZ="Asia/Kolkata"
clear

echo ""
echo "  ███████╗██╗   ██╗███████╗██╗  ██╗ █████╗ ███╗   ██╗"
echo "  ██╔════╝██║   ██║██╔════╝██║  ██║██╔══██╗████╗  ██║"
echo "  █████╗  ██║   ██║███████╗███████║███████║██╔██╗ ██║"
echo "  ██╔══╝  ██║   ██║╚════██║██╔══██║██╔══██║██║╚██╗██║"
echo "  ██║     ╚██████╔╝███████║██║  ██║██║  ██║██║ ╚████║"
echo "  ╚═╝      ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝"
echo ""

echo -e "Current Time: \t$(date '+%A, %d %B %Y %I:%M:%S %p %Z')"
echo ""
echo "═══════════════════════════════════════════════"
echo "              System Information               "
echo "═══════════════════════════════════════════════"
echo ""

echo -e "🟢 PHP Version: \t$(php -v 2>/dev/null | awk '/^PHP/ {print $2}' | head -n 1 || echo "Not installed")"
echo -e "🟡 Python Version: \t$(python3 -V 2>&1 | awk '{print $2}' || echo "Not installed")"
echo -e "🔵 MySQL Version: \t$(mysql -V 2>/dev/null | awk '{print $5}' | sed 's/,//')"
echo -e "🟣 cPanel Version: \t$(cat /usr/local/cpanel/version 2>/dev/null || echo "Not installed")"
echo -e "🟠 cPanel Build: \t$([ -x /usr/local/cpanel/cpanel ] && /usr/local/cpanel/cpanel -V 2>/dev/null | awk '/build/ {print $NF}' || echo "Not available")"

groups $(whoami) | grep -q '\bcompiler\b' && compiler_group="✅ YES" || compiler_group="❌ NO"
echo -e "🛠  Compiler Group: \t$compiler_group"

echo -e "🔑 TLS Version: \t$(openssl ciphers -v 2>/dev/null | awk '{print $2}' | sort | uniq | tail -1 || echo "Not available")"
echo -e "🌐 Apache Version: \t$([[ -f /etc/cpanel/ea4/is_ea4 ]] && echo "EA4" || echo "EA3")"

echo -e "🔄 Last Boot Time: \t$(last reboot | head -1 | awk '{print $5,$6,$7,$8}')"
echo -e "🏠 Home Dir Size: \t$(du -hs ~ 2>/dev/null | awk '{print $1}' | sed 's/G$/GB/' | sed 's/M$/MB/')"
echo -e "📂 Home Dir Path: \t$(echo ~)"

echo ""
echo "═══════════════════════════════════════════════"
echo "         Contact Information & Author          "
echo "═══════════════════════════════════════════════"
echo ""
echo "📝 Author:       Sushan"
echo "💼 Role:        Tech Tier3 Support Engineer"
echo "✉️  Email:       sushan@sush.com"
echo ""
echo '     ___________________________________________________________'
echo '    /                                                           \'
echo '   |   🎯 For more info, please contact Sushan                 |'
echo '   |   📩 Email: sushan@sush.com                               |'
echo '    \       ღ(¯`◕‿◕´¯)    c(◕ヮ◕n )     ¯´◕‿◕`¯(ღ        /'
echo '     -----------------------------------------------------------'
echo ""

read -p "Would you like to proceed to the next bash script? (y/n): " choice
if [[ $choice == "y" || $choice == "Y" ]]; then
    bash <(curl -s https://raw.githubusercontent.com/sushsushan/SSH/main/hits.sh)
else
    messages=("Goodbye!" "Have a nice day!" "Take care!" "See you later!" "Have a good one!" "Adios!" "Catch you later!" "Until next time!")
    echo " ${messages[$RANDOM % ${#messages[@]}]}"
fi
