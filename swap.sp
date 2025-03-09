#!/bin/bash

# Prompt user for account number
echo -n "Enter Account Number: "
read accountNumber

# Fetch data first to determine the server hostname
output=$(hal addon_list tenant_back_ref "$accountNumber" brand bluehost/hostgator order_by account_id select \
    id,type,status,account_id,account_username,server_hostname,server_id,meta_domain,back_reference | \
    sed 's/^[ \t]*//;s/[ \t]*$//')

# Extract the first matching server hostname from the output
server_hostname=$(echo "$output" | awk 'NR==2 {print $6}')

# Determine brand based on server hostname
if [[ $server_hostname == box*.bluehost.com ]]; then
    brand="bluehost"
elif [[ $server_hostname == gator*.hostgator.com ]]; then
    brand="hostgator"
else
    echo "Unknown server hostname: $server_hostname"
    exit 1
fi

# Run the final hal command with the correct brand
hal addon_list tenant_back_ref "$accountNumber" brand "$brand" order_by account_id select \
    id,type,status,account_id,account_username,server_hostname,server_id,meta_domain,back_reference
