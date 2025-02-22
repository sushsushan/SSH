#!/bin/bash

# Generate a unique token name (randomized each time)
TOKEN_NAME="tempemail_$(date +%s)"

# Generate expiration time (1 day from now)
EXPIRE_TIME=$(date -d "1 day" +%s)

# Generate a full-access token
API_RESPONSE=$(uapi Tokens create_full_access name="$TOKEN_NAME" expires_at="$EXPIRE_TIME")

# Extract the token value using grep and awk
TOKEN=$(echo "$API_RESPONSE" | grep -oP 'token:\s*\K\w+')

# Validate token extraction
if [[ -z "$TOKEN" ]]; then
    echo "Error: Failed to generate API token."
    exit 1
fi

# Set cPanel details
USERNAME=$(whoami)
HOSTNAME=$(hostname)
EMAIL_USER="techsupport"
PASSWORD="ds@4sd(<cvp"  # Use a secure password
DOMAIN="yourdomain.com"  # Fetch this dynamically if needed

# Create email account
curl -H "Authorization: cpanel $USERNAME:$TOKEN" "https://$HOSTNAME:2083/execute/Email/add_pop?email=$EMAIL_USER&password=$PASSWORD&domain=$DOMAIN"

# Get server IP
IP_ADDRESS=$(hostname -i)

# Generate webmail session
SESSION_RESPONSE=$(uapi Session create_webmail_session_for_mail_user_check_password login="$EMAIL_USER" domain="$DOMAIN" password="$PASSWORD" remote_address="$IP_ADDRESS")

# Extract session and token values
SESSION=$(echo "$SESSION_RESPONSE" | grep -oP 'session:\s*\K[\w@:.]+')
TOKEN_VALUE=$(echo "$SESSION_RESPONSE" | grep -oP 'token:\s*\K/cpsess\d+')

# Validate session extraction
if [[ -z "$SESSION" || -z "$TOKEN_VALUE" ]]; then
    echo "Error: Failed to generate webmail session."
    exit 1
fi

# Immediately revoke the API token
uapi Tokens revoke name="$TOKEN_NAME"

# Output only the login link for the user
echo "https://$HOSTNAME:2096$TOKEN_VALUE/login/?locale=en&session=$SESSION"
