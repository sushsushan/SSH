#!/bin/bash

# Check if user is root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root!"
   exit 1
fi

# Function to display active ports
list_ports() {
    echo "Scanning for open and listening ports..."
    echo "=========================================="
    netstat -tulnp 2>/dev/null | awk '$4 ~ /:/ {print $4, $1, $7}' | sed 's/.*://'
    echo "=========================================="
}

# Function to scan all ports using netstat
scan_ports() {
    echo "Scanning ports using netstat..."
    netstat -tulnp 2>/dev/null
    echo "=========================================="
}

# Function to test a specific port
test_port() {
    read -p "Enter the port number to check: " port
    read -p "Enter the IP/Hostname (default: localhost): " ip
    ip=${ip:-localhost}

    echo "Checking connectivity on $ip:$port..."
    
    if nc -zv "$ip" "$port" 2>&1 | grep -q "succeeded"; then
        echo "✅ Port $port is OPEN on $ip"
    else
        echo "❌ Port $port is CLOSED or FILTERED on $ip"
    fi
}

# Function to check all open, closed, listening ports using lsof
advanced_scan() {
    echo "Performing an advanced scan using lsof..."
    lsof -i -P -n | grep LISTEN
    echo "=========================================="
}

# Menu-driven options
while true; do
    echo -e "\n========= PORT SCANNER & TESTER ========="
    echo "1. List open and listening ports"
    echo "2. Scan all ports"
    echo "3. Test a specific port"
    echo "4. Perform an advanced scan (lsof)"
    echo "5. Exit"
    echo "=========================================="
    
    read -p "Choose an option: " choice

    case $choice in
        1) list_ports ;;
        2) scan_ports ;;
        3) test_port ;;
        4) advanced_scan ;;
        5) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
done
