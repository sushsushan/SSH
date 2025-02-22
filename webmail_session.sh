#!/bin/bash

# Generate a unique token name using timestamp
TOKEN_NAME="tempemail_$(date +%Y%m%d%H%M%S)"

# Get expiration time for 1 day from now
EXPIRE_TIME=$(date -d "1 day" +%s)

# Create a full access API token
TOKEN_RESPONSE=$(uapi Tokens create_full_access name="$TOKEN_NAME" expires_at="$EXPIRE_TIME" --output=json)

# Extract token value using grep and awk
TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"token": *"[^"]*' | awk -F'"' '{print $4}')

# Ensure token is retrieved
if [ -z "$TOKEN" ]; then
    echo "Error: Failed to generate API token."
    exit 1
fi

# Get hostname and username
HOSTNAME=$(hostname)
USERNAME=$(whoami)

# Prompt for the domain name
read -p "Enter the domain name: " DOMAIN

# Generate a strong password
PASSWORD=$(openssl rand -base64 12)

# Email account details
EMAIL_USER="techsupport"

# Create email account using cPanel API
EMAIL_RESPONSE=$(curl -s -H "Authorization: cpanel $USERNAME:$TOKEN" \
"https://$HOSTNAME:2083/execute/Email/add_pop?email=$EMAIL_USER&password=$PASSWORD&domain=$DOMAIN")

# Check if email creation was successful
if ! echo "$EMAIL_RESPONSE" | grep -q '"status":1'; then
    echo "Error: Failed to create email account."
    exit 1
fi

# Get the machine IP
IP_ADDRESS=$(hostname -i)

# Create webmail session
SESSION_RESPONSE=$(uapi Session create_webmail_session_for_mail_user_check_password \
login="$EMAIL_USER" domain="$DOMAIN" password="$PASSWORD" remote_address="$IP_ADDRESS" --output=json)

# Extract session and token values
SESSION=$(echo "$SESSION_RESPONSE" | grep -o '"session": *"[^"]*' | awk -F'"' '{print $4}')
WEBMAIL_TOKEN=$(echo "$SESSION_RESPONSE" | grep -o '"token": *"[^"]*' | awk -F'"' '{print $4}')

# Ensure session values are retrieved
if [ -z "$SESSION" ] || [ -z "$WEBMAIL_TOKEN" ]; then
    echo "Error: Failed to generate webmail session."
    exit 1
fi

# Display only the webmail login link to the user
echo "Your webmail login link: https://$HOSTNAME:2096$WEBMAIL_TOKEN/login/?locale=en&session=$SESSION"

# Schedule token revocation after 1 hour
echo "uapi Tokens revoke name='$TOKEN_NAME'" | at now + 1 hour
