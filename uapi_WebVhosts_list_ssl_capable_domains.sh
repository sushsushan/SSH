#!/bin/bash

# Fetch data
data=$(uapi WebVhosts list_ssl_capable_domains)

# Initialize arrays
domains=()
vhosts=()
proxies=()

# Read values into arrays
while read -r line; do
    if [[ $line == " domain:"* ]]; then
        domains+=("$(echo "$line" | awk '{print $2}')")
    fi
    if [[ $line == " vhost_name:"* ]]; then
        vhosts+=("$(echo "$line" | awk '{print $2}')")
    fi
    if [[ $line == " is_proxy:"* ]]; then
        proxies+=("$(echo "$line" | awk '{print $2}')")
    fi
done <<< "$data"

# Determine max column widths
max_domain=6
max_vhost=9
max_proxy=8  # "Is Proxy"

for i in "${!domains[@]}"; do
    [[ ${#domains[i]} -gt $max_domain ]] && max_domain=${#domains[i]}
    [[ ${#vhosts[i]} -gt $max_vhost ]] && max_vhost=${#vhosts[i]}
done

# Add padding
max_domain=$((max_domain + 2))
max_vhost=$((max_vhost + 2))

# Print header
printf "%-${max_domain}s | %-${max_vhost}s | %-${max_proxy}s\n" "Domain" "VHost Name" "Is Proxy"
printf "%-${max_domain}s | %-${max_vhost}s | %-${max_proxy}s\n" "$(printf -- '-%.0s' $(seq 1 $max_domain))" "$(printf -- '-%.0s' $(seq 1 $max_vhost))" "$(printf -- '-%.0s' $(seq 1 $max_proxy))"

# Print records
for i in "${!domains[@]}"; do
    printf "%-${max_domain}s | %-${max_vhost}s | %-${max_proxy}s\n" "${domains[i]}" "${vhosts[i]}" "${proxies[i]}"
done
