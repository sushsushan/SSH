#!/bin/bash

echo "1) System-generated DB name/user  2) Enter your own DB name/user"
read -p "Choose (1/2): " choice

HOST_USER=$(whoami)

if [[ "$choice" == "1" ]]; then
    DB_NAME="db_$(date +%s)"
    DB_USER="${HOST_USER}_${DB_NAME}"
else
    read -p "Enter DB name: " DB_NAME
    DB_USER="${HOST_USER}_$DB_NAME"
fi

DB_PASS=$(openssl rand -base64 12)
FULL_DB_NAME="${HOST_USER}_${DB_NAME}"
DB_HOST="localhost"

echo "Creating database..."
uapi Mysql create_database name="$FULL_DB_NAME" >/dev/null 2>&1

echo "Creating user..."
uapi Mysql create_user name="$DB_USER" password="$DB_PASS" >/dev/null 2>&1

echo "Setting privileges..."
uapi Mysql set_privileges_on_database database="$FULL_DB_NAME" user="$DB_USER" privileges="ALL PRIVILEGES" >/dev/null 2>&1

# Prompt user for path to save db_connect.php
read -p "Enter the path where you want to save db_connect.php: " FILE_PATH

# Ensure the directory exists
mkdir -p "$FILE_PATH"

# Create db_connect.php
DB_CONNECT_FILE="$FILE_PATH/db_connect.php"

cat <<EOF > "$DB_CONNECT_FILE"
<?php
\$db_host = '$DB_HOST';
\$db_name = '$FULL_DB_NAME';
\$db_user = '$DB_USER';
\$db_pass = '$DB_PASS';

try {
    \$conn = new PDO("mysql:host=\$db_host;dbname=\$db_name", \$db_user, \$db_pass);
    \$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "Database connection successful!";
} catch (PDOException \$e) {
    echo "Connection failed: " . \$e->getMessage();
}
?>
EOF

# Set correct permissions
chmod 644 "$DB_CONNECT_FILE"

echo -e "\nDatabase setup completed!"
echo -e "Database Name: $FULL_DB_NAME"
echo -e "Database User: $DB_USER"
echo -e "Database Password: $DB_PASS"
echo -e "Database Host: $DB_HOST"
echo -e "File Created: $DB_CONNECT_FILE"

