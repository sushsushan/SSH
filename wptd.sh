#!/bin/bash

# AI-Based Email Header Analyzer - Converts raw email headers into a human-readable format

analyze_header() {
    local header="$1"
    
    # Extracting Important Fields
    echo -e "\n\033[1;34m=== Extracted Header Information ===\033[0m\n"

    from=$(echo "$header" | grep -i "^From:" | head -1 | sed 's/^From: //I')
    to=$(echo "$header" | grep -i "^To:" | head -1 | sed 's/^To: //I')
    subject=$(echo "$header" | grep -i "^Subject:" | head -1 | sed 's/^Subject: //I')
    date=$(echo "$header" | grep -i "^Date:" | head -1 | sed 's/^Date: //I')
    return_path=$(echo "$header" | grep -i "^Return-Path:" | head -1 | sed 's/^Return-Path: //I')
    message_id=$(echo "$header" | grep -i "^Message-ID:" | head -1 | sed 's/^Message-ID: //I')
    
    echo -e "\033[1;32mFrom: \033[0m$from"
    echo -e "\033[1;32mTo: \033[0m$to"
    echo -e "\033[1;32mSubject: \033[0m$subject"
    echo -e "\033[1;32mDate: \033[0m$date"
    echo -e "\033[1;32mReturn-Path: \033[0m$return_path"
    echo -e "\033[1;32mMessage-ID: \033[0m$message_id"

    # Extract sender IP
    sender_ip=$(echo "$header" | grep -oP '(?<=Received: from ).*?\[.*?\]' | grep -oP '\d+\.\d+\.\d+\.\d+' | head -1)
    echo -e "\n\033[1;34m=== IP & Email Authentication Analysis ===\033[0m\n"
    echo -e "\033[1;32mSender IP: \033[0m$sender_ip"

    # Extract SPF, DKIM, and DMARC Results
    spf_result=$(echo "$header" | grep -i "spf=" | head -1)
    dkim_result=$(echo "$header" | grep -i "dkim=" | head -1)
    dmarc_result=$(echo "$header" | grep -i "dmarc=" | head -1)

    echo -e "\033[1;32mSPF Authentication: \033[0m$spf_result"
    echo -e "\033[1;32mDKIM Authentication: \033[0m$dkim_result"
    echo -e "\033[1;32mDMARC Authentication: \033[0m$dmarc_result"

    # WHOIS Lookup for Sender IP
    echo -e "\n\033[1;34m=== WHOIS & Geolocation Information ===\033[0m\n"
    if [[ -n "$sender_ip" ]]; then
        echo -e "\033[1;32mWHOIS Lookup for $sender_ip:\033[0m"
        whois "$sender_ip" | grep -E 'OrgName|Country|NetRange|CIDR|OrgAbuseEmail' | sed 's/^/  /'

        # IP Geolocation using ipinfo.io
        echo -e "\n\033[1;32mGeolocation for $sender_ip:\033[0m"
        curl -s "https://ipinfo.io/$sender_ip/json" | jq '.city, .region, .country, .org' | sed 's/^/  /'
    else
        echo -e "\033[1;31mNo Sender IP Found!\033[0m"
    fi

    # Extract sender domain
    domain=$(echo "$from" | grep -oP '(?<=@)[^>]+')
    if [[ -n "$domain" ]]; then
        echo -e "\n\033[1;34m=== Domain Analysis ===\033[0m\n"
        echo -e "\033[1;32mDNS Lookup for $domain:\033[0m"
        dig +short "$domain"
    fi

    # Spoofing and Security Analysis
    echo -e "\n\033[1;34m=== Spoofing & Security Risk Analysis ===\033[0m\n"

    if [[ "$spf_result" =~ "fail" ]]; then
        echo -e "\033[1;31mWarning: SPF Failed - Possible Spoofing Detected!\033[0m"
    fi

    if [[ "$dkim_result" =~ "fail" ]]; then
        echo -e "\033[1;31mWarning: DKIM Failed - Email Integrity Not Verified!\033[0m"
    fi

    if [[ "$dmarc_result" =~ "fail" ]]; then
        echo -e "\033[1;31mWarning: DMARC Failed - Possible Phishing or Spoofing Attempt!\033[0m"
    fi

    echo -e "\n\033[1;34m=== Full Header Dump ===\033[0m\n"
    echo "$header"
}

# User input for email header
echo -e "\033[1;36mPaste the full email header (Press Ctrl+D when done):\033[0m"
email_header=$(cat)

# Run analysis
analyze_header "$email_header"
