#!/bin/bash

# WordPress Management Script for cPanel Server
# Version: 1.0 | Author: Your Name | Advanced WordPress Control
# Required: WP-CLI, cPanel Access, MySQL, tar, gzip, rsync, find

WP_CLI="/usr/local/bin/wp"  # Adjust if wp-cli is in a different location
BACKUP_DIR="/root/wp_backups"
LOG_FILE="/var/log/wp-manager.log"

# Detect all WordPress installations
function list_wp_sites() {
    echo -e "\n🔍 Searching for WordPress installations..."
    find /home/*/public_html -name "wp-config.php" 2>/dev/null | sed 's|/wp-config.php||' | tee /tmp/wp_sites.list
}

# Backup WordPress (files + database)
function backup_wp() {
    list_wp_sites
    echo -e "\n📦 Creating backups..."
    mkdir -p "$BACKUP_DIR"
    while read -r site; do
        domain=$(basename "$site")
        timestamp=$(date +"%Y%m%d_%H%M%S")
        backup_name="${domain}_backup_${timestamp}.tar.gz"
        db_name=$($WP_CLI --path="$site" config get DB_NAME)
        db_user=$($WP_CLI --path="$site" config get DB_USER)
        db_pass=$($WP_CLI --path="$site" config get DB_PASSWORD)

        mysqldump -u "$db_user" -p"$db_pass" "$db_name" > "$BACKUP_DIR/${domain}_db.sql"
        tar -czf "$BACKUP_DIR/$backup_name" "$site" "$BACKUP_DIR/${domain}_db.sql"
        rm -f "$BACKUP_DIR/${domain}_db.sql"
        echo "✅ Backup created: $BACKUP_DIR/$backup_name" | tee -a "$LOG_FILE"
    done < /tmp/wp_sites.list
}

# Restore WordPress from backup
function restore_wp() {
    echo -e "\n🛠 Available Backups:\n"
    ls -lh "$BACKUP_DIR"/*.tar.gz
    read -p "Enter backup filename to restore: " backup_file
    tar -xzf "$BACKUP_DIR/$backup_file" -C /
    echo "✅ Restored: $backup_file"
}

# Update WordPress core, plugins, and themes
function update_wp() {
    list_wp_sites
    echo -e "\n⚡ Updating WordPress Core, Plugins & Themes..."
    while read -r site; do
        echo "🔄 Updating $site..."
        $WP_CLI --path="$site" core update
        $WP_CLI --path="$site" plugin update --all
        $WP_CLI --path="$site" theme update --all
        echo "✅ Updated: $site" | tee -a "$LOG_FILE"
    done < /tmp/wp_sites.list
}

# Enable Security Hardening
function security_hardening() {
    list_wp_sites
    echo -e "\n🔐 Applying security measures..."
    while read -r site; do
        $WP_CLI --path="$site" config set DISALLOW_FILE_EDIT true
        $WP_CLI --path="$site" config set WP_DISABLE_FATAL_ERROR_HANDLER true
        $WP_CLI --path="$site" plugin install wordfence --activate
        $WP_CLI --path="$site" rewrite flush
        echo "✅ Security settings applied: $site"
    done < /tmp/wp_sites.list
}

# Optimize Database
function optimize_db() {
    list_wp_sites
    echo -e "\n🛠 Optimizing databases..."
    while read -r site; do
        $WP_CLI --path="$site" db optimize
        $WP_CLI --path="$site" db clean
        echo "✅ Database optimized: $site"
    done < /tmp/wp_sites.list
}

# List all WordPress users
function list_wp_users() {
    list_wp_sites
    while read -r site; do
        echo -e "\n👤 Users for $site:"
        $WP_CLI --path="$site" user list
    done < /tmp/wp_sites.list
}

# Change WordPress User Password
function reset_wp_password() {
    list_wp_sites
    read -p "Enter WordPress username to reset password: " username
    read -sp "Enter new password: " new_password
    while read -r site; do
        $WP_CLI --path="$site" user update "$username" --user_pass="$new_password"
        echo -e "\n✅ Password changed for $username in $site"
    done < /tmp/wp_sites.list
}

# Check WordPress Site Health
function check_wp_status() {
    list_wp_sites
    while read -r site; do
        echo -e "\n📊 Checking Status for $site:"
        $WP_CLI --path="$site" core check-update
        $WP_CLI --path="$site" plugin list --update=available
        $WP_CLI --path="$site" theme list --update=available
        echo "✅ Status check completed for: $site"
    done < /tmp/wp_sites.list
}

# Malware Scanner (Basic)
function scan_malware() {
    list_wp_sites
    echo -e "\n🦠 Scanning for malware..."
    while read -r site; do
        clamscan -r "$site" --quiet --log="$LOG_FILE"
    done < /tmp/wp_sites.list
    echo "✅ Scan complete. Check logs for details."
}

# Menu Interface
while true; do
    echo -e "\n🔹 WordPress Management Tool 🔹"
    echo "1) List WordPress Sites"
    echo "2) Backup WordPress"
    echo "3) Restore Backup"
    echo "4) Update WordPress (Core, Plugins, Themes)"
    echo "5) Apply Security Hardening"
    echo "6) Optimize Database"
    echo "7) List WP Users"
    echo "8) Reset WP User Password"
    echo "9) Check Site Status"
    echo "10) Scan for Malware"
    echo "0) Exit"
    read -p "Select an option: " choice

    case $choice in
        1) list_wp_sites ;;
        2) backup_wp ;;
        3) restore_wp ;;
        4) update_wp ;;
        5) security_hardening ;;
        6) optimize_db ;;
        7) list_wp_users ;;
        8) reset_wp_password ;;
        9) check_wp_status ;;
        10) scan_malware ;;
        0) exit ;;
        *) echo "❌ Invalid option! Try again." ;;
    esac
done
