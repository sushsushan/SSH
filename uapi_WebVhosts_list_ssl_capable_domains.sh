#!/bin/bash

# Fetch the data
data=$(uapi WebVhosts list_ssl_capable_domains)

# Extract values while determining max column widths
max_domain=10
max_vhost=10

while read -r line; do
    if [[ $line == " domain:"* ]]; then
        domain=$(echo "$line" | awk '{print $2}')
        [[ ${#domain} -gt $max_domain ]] && max_domain=${#domain}
    fi
    if [[ $line == " vhost_name:"* ]]; then
        vhost=$(echo "$line" | awk '{print $2}')
        [[ ${#vhost} -gt $max_vhost ]] && max_vhost=${#vhost}
    fi
done <<< "$data"

# Add padding to column widths
max_domain=$((max_domain + 5))
max_vhost=$((max_vhost + 5))

# Print header
printf "%-${max_domain}s | %-${max_vhost}s | %-7s\n" "Domain" "VHost Name" "Is Proxy"
printf "%-${max_domain}s | %-${max_vhost}s | %-7s\n" "$(printf -- '-%.0s' $(seq 1 $max_domain))" "$(printf -- '-%.0s' $(seq 1 $max_vhost))" "-------"

# Print records in aligned format
while read -r line; do
    if [[ $line == " domain:"* ]]; then
        domain=$(echo "$line" | awk '{print $2}')
    fi
    if [[ $line == " vhost_name:"* ]]; then
        vhost=$(echo "$line" | awk '{print $2}')
    fi
    if [[ $line == " is_proxy:"* ]]; then
        is_proxy=$(echo "$line" | awk '{print $2}')
        printf "%-${max_domain}s | %-${max_vhost}s | %-7s\n" "$domain" "$vhost" "$is_proxy"
    fi
done <<< "$data"
