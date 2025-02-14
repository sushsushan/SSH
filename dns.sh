#!/bin/bash

# Function to check if required commands exist
check_command() {
    command -v "$1" >/dev/null 2>&1 || { echo -e "\033[31m[ERROR]\033[0m $1 is required but not installed. Aborting."; exit 1; }
}

# Ensure required utilities are installed
check_command dig
check_command whois
check_command awk
check_command grep
check_command sed

# Prompt user for domain until a valid input is provided
while [[ -z "$domain" ]]; do
    read -p "\033[34mEnter domain name: \033[0m" domain
    if [[ -z "$domain" ]]; then
        echo -e "\033[31m[ERROR]\033[0m Domain name cannot be empty. Please enter a valid domain."
    fi
done

echo -e "\n\033[32mFetching DNS Records for: $domain\033[0m\n"

# Check if the domain is registered
whois_output=$(whois $domain 2>/dev/null)
if echo "$whois_output" | grep -q "No match"; then
    echo -e "\033[31m[ERROR]\033[0m The domain '$domain' is not registered."
    read -p "Would you like to check domain registration info? (y/n): " check_reg
    if [[ "$check_reg" == "y" || "$check_reg" == "Y" ]]; then
        echo -e "\033[33mYou can register this domain through a registrar.\033[0m"
    fi
    exit 1
fi

echo "------------------------------------------------------------"
echo -e "\033[36mA Record (IPv4 Address):\033[0m"
dig +short A $domain || echo "No A record found."

echo "------------------------------------------------------------"
echo -e "\033[36mAAAA Record (IPv6 Address):\033[0m"
dig +short AAAA $domain || echo "No AAAA record found."

echo "------------------------------------------------------------"
echo -e "\033[36mCNAME Record (Canonical Name):\033[0m"
dig +short CNAME $domain || echo "No CNAME record found."

echo "------------------------------------------------------------"
echo -e "\033[36mMX Records (Mail Exchange):\033[0m"
dig MX $domain +short | sort -n || echo "No MX records found."

echo "------------------------------------------------------------"
echo -e "\033[36mNS Records (Name Servers):\033[0m"
dig NS $domain +short || echo "No NS records found."

echo "------------------------------------------------------------"
echo -e "\033[36mTXT Records (Text Records):\033[0m"
dig TXT $domain +short || echo "No TXT records found."

echo "------------------------------------------------------------"
echo -e "\033[36mSOA Record (Start of Authority):\033[0m"
dig SOA $domain +short || echo "No SOA record found."

echo "------------------------------------------------------------"
echo -e "\033[36mSRV Records (Service Records):\033[0m"
dig SRV $domain +short || echo "No SRV records found."

echo "------------------------------------------------------------"
echo -e "\033[36mPTR Record (Reverse DNS - if available):\033[0m"
reverse_ip=$(dig +short A $domain | head -n 1 | awk -F '.' '{print $4"."$3"."$2"."$1 ".in-addr.arpa"}')
[ -n "$reverse_ip" ] && dig -x $reverse_ip +short || echo "No PTR record found."

echo "------------------------------------------------------------"
echo -e "\033[36mDNSSEC Information:\033[0m"
dig DNSKEY $domain +short || echo "DNSSEC not enabled."

echo "------------------------------------------------------------"
echo -e "\033[36mWHOIS Information:\033[0m"
echo "$whois_output" | grep -E "^(Domain Name|Registry Expiry Date|Updated Date|Creation Date|Registrar|Registrant|Admin|Tech)" || echo "No WHOIS data found."

echo "------------------------------------------------------------"
echo -e "\033[32mProcess Completed. All records displayed above.\033[0m\n"
