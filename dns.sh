#!/bin/bash

# Function to check if required commands exist
check_command() {
    command -v "$1" >/dev/null 2>&1 || { echo >&2 "$1 is required but not installed. Aborting."; exit 1; }
}

# Ensure required utilities are installed
check_command dig
check_command whois
check_command awk
check_command grep
check_command sed

# Read domain from user
read -p "Enter domain name: " domain

echo -e "\nFetching DNS Records for: $domain\n"

echo "------------------------------------------------------------"
echo "A Record (IPv4 Address):"
dig +short A $domain

echo "------------------------------------------------------------"
echo "AAAA Record (IPv6 Address):"
dig +short AAAA $domain

echo "------------------------------------------------------------"
echo "CNAME Record (Canonical Name):"
dig +short CNAME $domain

echo "------------------------------------------------------------"
echo "MX Records (Mail Exchange):"
dig MX $domain +short | sort -n

echo "------------------------------------------------------------"
echo "NS Records (Name Servers):"
dig NS $domain +short

echo "------------------------------------------------------------"
echo "TXT Records (Text Records):"
dig TXT $domain +short

echo "------------------------------------------------------------"
echo "SOA Record (Start of Authority):"
dig SOA $domain +short

echo "------------------------------------------------------------"
echo "SRV Records (Service Records):"
dig SRV $domain +short

echo "------------------------------------------------------------"
echo "PTR Record (Reverse DNS - if available):"
reverse_ip=$(dig +short A $domain | head -n 1 | awk -F '.' '{print $4"."$3"."$2"."$1 ".in-addr.arpa"}')
[ -n "$reverse_ip" ] && dig -x $reverse_ip +short || echo "No PTR record found."

echo "------------------------------------------------------------"
echo "DNSSEC Information:"
dig DNSKEY $domain +short || echo "DNSSEC not enabled."

echo "------------------------------------------------------------"
echo "WHOIS Information:"
whois $domain | grep -E "^(Domain Name|Registry Expiry Date|Updated Date|Creation Date|Registrar|Registrant|Admin|Tech)"

echo "------------------------------------------------------------"
echo "Process Completed. All records displayed above.\n"
