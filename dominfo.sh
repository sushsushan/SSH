#!/bin/bash

# Run the uapi command to get domain details in JSON format
json_output=$(uapi --output=jsonpretty DomainInfo domains_data)

# Check if jq is installed, if not, prompt the user to install it
if ! command -v jq &>/dev/null; then
    echo "Error: 'jq' is not installed. Install it using 'yum install jq' or 'apt install jq'."
    exit 1
fi

# Extract domain information using jq
domain_data=$(echo "$json_output" | jq -r '.result.data[] | [.domain, .documentroot, .type] | @tsv')

# Define table headers
printf "%-40s %-60s %-15s\n" "Domain Name" "Document Root/Path" "Type"
printf "%-40s %-60s %-15s\n" "----------------------------------------" "------------------------------------------------------------" "---------------"

# Print the extracted data in a well-aligned format
while IFS=$'\t' read -r domain docroot type; do
    printf "%-40s %-60s %-15s\n" "$domain" "$docroot" "$type"
done <<< "$domain_data"
