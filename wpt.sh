#!/bin/bash

# Email Header Analyzer Script
# Dependencies: curl, jq, whois, dig

analyze_header() {
    local header="$1"

    echo -e "\n=== Extracted Header Information ===\n"

    # Extract sender IP
    sender_ip=$(echo "$header" | grep -oP '(?<=Received: from ).*?\[.*?\]' | grep -oP '\d+\.\d+\.\d+\.\d+' | head -1)
    echo "Sender IP: $sender_ip"

    # Extract SPF Authentication
    spf_result=$(echo "$header" | grep -i "spf=" | head -1)
    echo "SPF Authentication: $spf_result"

    # Extract DKIM Authentication
    dkim_result=$(echo "$header" | grep -i "dkim=" | head -1)
    echo "DKIM Authentication: $dkim_result"

    # Extract DMARC Authentication
    dmarc_result=$(echo "$header" | grep -i "dmarc=" | head -1)
    echo "DMARC Authentication: $dmarc_result"

    echo -e "\n=== IP and Domain Analysis ===\n"

    # WHOIS Lookup
    if [[ -n "$sender_ip" ]]; then
        echo "WHOIS Lookup for $sender_ip:"
        whois "$sender_ip" | grep -E 'OrgName|Country|NetRange|CIDR|OrgAbuseEmail' | sed 's/^/  /'
    fi

    # IP Geolocation (Using ipinfo.io)
    if [[ -n "$sender_ip" ]]; then
        echo -e "\nGeolocation for $sender_ip:"
        curl -s "https://ipinfo.io/$sender_ip/json" | jq '.city, .region, .country, .org' | sed 's/^/  /'
    fi

    # Domain Lookup
    domain=$(echo "$header" | grep -oP '(?<=From: ).*?<' | grep -oP '(?<=@)[^>]+')
    if [[ -n "$domain" ]]; then
        echo -e "\nDNS Lookup for $domain:"
        dig +short "$domain"
    fi

    echo -e "\n=== Spoofing and Security Analysis ===\n"

    if [[ "$spf_result" =~ "fail" ]]; then
        echo "Warning: SPF Failed - Possible Spoofing Detected!"
    fi

    if [[ "$dkim_result" =~ "fail" ]]; then
        echo "Warning: DKIM Failed - Email Integrity Not Verified!"
    fi

    if [[ "$dmarc_result" =~ "fail" ]]; then
        echo "Warning: DMARC Failed - Possible Phishing or Spoofing Attempt!"
    fi
}

# User input for email header
echo "Paste the full email header (Press Ctrl+D when done):"
email_header=$(cat)

# Run analysis
analyze_header "$email_header"
