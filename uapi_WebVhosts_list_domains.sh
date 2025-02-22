#!/bin/bash

# Running uapi WebVhosts list_domains command and capturing output
output=$(uapi WebVhosts list_domains)

# Header for the CSV output
echo "domain,proxy_subdomain,vhost_is_ssl,vhost_name"

# Loop through the output and format it into CSV-like structure
domain=""
proxy_subdomains=""
vhost_is_ssl=""
vhost_name=""

while IFS= read -r line; do
    if [[ $line == domain:* ]]; then
        if [[ -n $domain ]]; then
            # Print the previous record in CSV format
            echo "$domain,\"$proxy_subdomains\",$vhost_is_ssl,$vhost_name"
        fi
        # Extract domain name
        domain=$(echo "$line" | awk '{print $2}')
    elif [[ $line == proxy_subdomains:* ]]; then
        # Extract proxy subdomains, remove leading and trailing spaces
        proxy_subdomains=$(echo "$line" | sed 's/proxy_subdomains://;s/^\s*//;s/\s*$//')
        proxy_subdomains=$(echo "$proxy_subdomains" | tr -d '\n' | sed 's/- / /g')  # Format subdomains into a single string
    elif [[ $line == vhost_is_ssl:* ]]; then
        # Extract SSL status
        vhost_is_ssl=$(echo "$line" | awk '{print $2}')
    elif [[ $line == vhost_name:* ]]; then
        # Extract vhost name
        vhost_name=$(echo "$line" | awk '{print $2}')
    fi
done <<< "$output"

# Make sure to print the last record after the loop
if [[ -n $domain ]]; then
    echo "$domain,\"$proxy_subdomains\",$vhost_is_ssl,$vhost_name"
fi
