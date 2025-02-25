#!/bin/bash

# Generate a unique token
TOKEN_RESPONSE=$(uapi Tokens create_full_access name="example")
TOKEN=$(echo "$TOKEN_RESPONSE" | grep -oP '(?<=token: )\S+')
SESSION_CREATE_TIME=$(echo "$TOKEN_RESPONSE" | grep -oP '(?<=create_time: )\S+')

# Get hostname and user
HOSTNAME=$(hostname)
CPANEL_USER=$(whoami)

# Generate a random email suffix
RAND_NUM=$((1000 + RANDOM % 9000))
EMAIL_USER="techsupport${RAND_NUM}"

# Get domain name from user input
read -p "Enter domain name: " DOMAIN_NAME

# Generate a strong random password
EMAIL_PASS=$(openssl rand -base64 12)

# Create email account using cURL
curl -H "Authorization: cpanel $CPANEL_USER:$TOKEN" \
    "https://${HOSTNAME}:2083/execute/Email/add_pop?email=${EMAIL_USER}&password=${EMAIL_PASS}&domain=${DOMAIN_NAME}"

# Get server IP
SERVER_IP=$(hostname -i)

# Generate webmail session
WEBMAIL_SESSION=$(uapi Session create_webmail_session_for_mail_user_check_password \
    login="${EMAIL_USER}" domain="${DOMAIN_NAME}" password="${EMAIL_PASS}" remote_address="${SERVER_IP}")

# Extract session token
SESSION_TOKEN=$(echo "$WEBMAIL_SESSION" | grep -oP '(?<=session: )\S+')

# Provide the login link
echo "Your webmail session link:"
echo "https://${HOSTNAME}:2096/cpsess${SESSION_TOKEN}/login/?locale=en&session=complete"

# Revoke the token
uapi Tokens revoke name="example"
