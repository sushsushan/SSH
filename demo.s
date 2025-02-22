#!/bin/bash

# Run uapi command and store the result
result=$(uapi DomainInfo domains_data)

# Extract main information
ip=$(echo "$result" | grep -i "ip:" | awk '{print $2}')
homedir=$(echo "$result" | grep -i "homedir:" | awk '{print $2}')
serveradmin=$(echo "$result" | grep -i "serveradmin:" | awk '{print $2}')
serveralias=$(echo "$result" | grep -i "serveralias:" | awk '{print $2}')
servername=$(echo "$result" | grep -i "servername:" | awk '{print $2}')
user=$(echo "$result" | grep -i "user:" | awk '{print $2}')

# Extract header information
domain=$(echo "$result" | grep -i "domain:" | awk '{print $2}')
type=$(echo "$result" | grep -i "type:" | awk '{print $2}')
documentroot=$(echo "$result" | grep -i "documentroot:" | awk '{print $2}')
userdirprotect=$(echo "$result" | grep -i "userdirprotect:" | awk '{print $2}')

# Print formatted result
echo "Main Information:"
echo "IP: $ip"
echo "Homedir: $homedir"
echo "Serveradmin: $serveradmin"
echo "Serveralias: $serveralias"
echo "Servername: $servername"
echo "User: $user"
echo ""
echo "Header Information:"
echo "Domain: $domain"
echo "Type: $type"
echo "Documentroot: $documentroot"
echo "Userdirprotect: $userdirprotect"
