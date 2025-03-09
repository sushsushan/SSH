#!/bin/bash

# Prompt user for accountNumber
echo -n "Enter account number: "
read accountNumber

# Run the initial HAL command to fetch data
output=$(hal addon_list tenant_back_ref "$accountNumber" brand bluehost/hostgator order_by account_id select id,type,status,account_id,account_username,server_hostname,server_id,meta_domain,back_reference | sed 's/^[ \t]*//;s/[ \t]*$//')

# Extract server_hostname from the output
server_hostname=$(echo "$output" | awk '{print $7}')  # Assuming server_hostname is the 7th column

# Determine the brand based on server_hostname
if [[ "$server_hostname" == box*.bluehost.com ]]; then
    brand="bluehost"
elif [[ "$server_hostname" == gator*.hostgator.com ]]; then
    brand="hostgator"\else
    echo "Unknown server hostname format: $server_hostname"
    exit 1
fi

# Run the HAL command with the determined brand
echo "Using brand: $brand"
hal addon_list tenant_back_ref "$accountNumber" brand "$brand" order_by account_id select id,type,status,account_id,account_username,server_hostname,server_id,meta_domain,back_reference
