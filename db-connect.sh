#!/bin/bash

# Prompt for database name choice
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

# Function to check UAPI execution
check_command() {
    if [[ $? -ne 0 ]]; then
        echo "Error: $1 failed!"
        exit 1
    fi
}

# Create database
echo "Creating database..."
uapi Mysql create_database name="$FULL_DB_NAME"
check_command "Database creation"

# Create user
echo "Creating user..."
uapi Mysql create_user name="$DB_USER" password="$DB_PASS"
check_command "User creation"

# Assign privileges
echo "Setting privileges..."
uapi Mysql set_privileges_on_database database="$FULL_DB_NAME" user="$DB_USER" privileges="ALL PRIVILEGES"
check_command "Assigning privileges"

# Double-check database user privileges
echo "Verifying database user privileges..."
uapi Mysql get_privileges_on_database database="$FULL_DB_NAME" user="$DB_USER"
check_command "Privilege verification"

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
    \$conn = new PDO("mysql:host=\$db_host;dbname=\$db_name;charset=utf8", \$db_user, \$db_pass);
    \$conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "✅ Database connection successful!";
} catch (PDOException \$e) {
    die("❌ Connection failed: " . \$e->getMessage());
}
?>
EOF

# Set correct permissions
chmod 644 "$DB_CONNECT_FILE"

echo -e "\n✅ Database setup completed successfully!"
echo -e "📂 File Created: $DB_CONNECT_FILE"
echo -e "📌 Database Name: $FULL_DB_NAME"
echo -e "👤 Database User: $DB_USER"
echo -e "🔑 Database Password: $DB_PASS"
echo -e "🖥️ Database Host: $DB_HOST"

echo -e "\nTest the connection by accessing: $DB_CONNECT_FILE"
