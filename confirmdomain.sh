#!/bin/bash

# Prompt user for domain name
read -p "Enter the domain name (e.g., example.com): " DOMAIN

# Prompt user for the document root path
read -p "Enter the document root path (e.g., /var/www/html/example.com): " DOCROOT

# Check if the provided directory exists
if [ ! -d "$DOCROOT" ]; then
    echo "Error: The provided directory does not exist."
    exit 1
fi

# Navigate to document root
cd "$DOCROOT" || exit 1

# Generate a test file
FILENAME="index.html"
if [ -f "$FILENAME" ]; then
    FILENAME="test_$(date +%s).html"
fi

# Create a test HTML file
echo "<html><body><h1>Server Test File</h1></body></html>" > "$FILENAME"

# Check if the file is accessible via the domain
URL="http://$DOMAIN/$FILENAME"
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "$URL")

# Validate response
if [ "$RESPONSE" -eq 200 ]; then
    echo "✅ The domain $DOMAIN is fetching content from this server."
else
    echo "❌ The domain $DOMAIN is NOT hosted on this server."
    echo "🔍 Ensure there are no permission issues and the document root is correct."
fi

# Clean up - Remove the test file
rm -f "$FILENAME"

exit 0
