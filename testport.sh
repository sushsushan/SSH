#!/bin/bash

# Function to list open and listening ports
list_ports() {
    echo "Scanning for open and listening ports..."
    echo "=========================================="
    
    if command -v ss &>/dev/null; then
        ss -tuln | awk '{print $1, $4}' | grep -E "LISTEN|ESTAB" | sed 's/.*://'
    elif command -v netstat &>/dev/null; then
        netstat -tuln | awk '{print $1, $4}' | sed 's/.*://'
    else
        echo "Neither ss nor netstat found. Install net-tools."
    fi

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

# Function to perform an advanced scan (non-root)
advanced_scan() {
    echo "Performing an advanced scan..."
    lsof -i -P -n 2>/dev/null | grep LISTEN || echo "No listening ports found."
    echo "=========================================="
}

# Menu-driven options
while true; do
    echo -e "\n========= NON-ROOT PORT SCANNER ========="
    echo "1. List open and listening ports"
    echo "2. Test a specific port"
    echo "3. Perform an advanced scan (lsof)"
    echo "4. Exit"
    echo "=========================================="
    
    read -p "Choose an option: " choice

    case $choice in
        1) list_ports ;;
        2) test_port ;;
        3) advanced_scan ;;
        4) echo "Exiting..."; exit 0 ;;
        *) echo "Invalid option. Please try again." ;;
    esac
done
