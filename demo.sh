#!/bin/bash

# Run uapi command to get the domain information
uapi DomainInfo domains_data | while read -r line; do
    # Extract key pieces of information from the uapi output
    ip=$(echo "$line" | grep -i "^ip:" | awk '{print $2}')
    homedir=$(echo "$line" | grep -i "^homedir:" | awk '{print $2}')
    serveradmin=$(echo "$line" | grep -i "^serveradmin:" | awk '{print $2}')
    serveralias=$(echo "$line" | grep -i "^serveralias:" | awk '{print $2}')
    servername=$(echo "$line" | grep -i "^servername:" | awk '{print $2}')
    user=$(echo "$line" | grep -i "^user:" | awk '{print $2}')
    domain=$(echo "$line" | grep -i "^domain:" | awk '{print $2}')
    type=$(echo "$line" | grep -i "^type:" | awk '{print $2}')
    documentroot=$(echo "$line" | grep -i "^documentroot:" | awk '{print $2}')
    userdirprotect=$(echo "$line" | grep -i "^userdirprotect:" | awk '{print $2}')

    # Handle cases where some fields are missing or empty
    serveradmin=${serveradmin:-"N/A"}
    serveralias=${serveralias:-"N/A"}
    servername=${servername:-"N/A"}
    user=${user:-"N/A"}
    userdirprotect=${userdirprotect:-"N/A"}

    # Print the main information
    echo "Main Info:"
    echo "--------------------------------------------"
    echo "IP:            $ip"
    echo "Homedir:       $homedir"
    echo "Serveradmin:   $serveradmin"
    echo "Serveralias:   $serveralias"
    echo "Servername:    $servername"
    echo "User:          $user"
    echo "--------------------------------------------"
    
    # Print a separator line for readability
    echo ""
    
    # Print the header for the detailed table
    if [[ -z $header_printed ]]; then
        printf "%-25s %-10s %-45s %-20s\n" "Domain" "Type" "Documentroot" "Userdirprotect"
        echo "---------------------------------------------------------------"
        header_printed=1
    fi
    
    # Print the details in the table format
    printf "%-25s %-10s %-45s %-20s\n" "$domain" "$type" "$documentroot" "$userdirprotect"
    
    # Add a blank line between records for readability
    echo ""
done
