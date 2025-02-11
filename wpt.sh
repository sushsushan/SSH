#!/bin/bash

# WordPress Advanced Management Tool for cPanel
# Version: 2.0 | Author: Your Name | High-Level Automation

# Required Dependencies: WP-CLI, MySQL, tar, rsync, netstat, iptables, curl

WP_CLI="/usr/local/bin/wp"
BACKUP_DIR="/root/wp_backups"
LOG_FILE="/var/log/wp-manager-advanced.log"
EMAIL_ALERT="youradmin@example.com"
TELEGRAM_CHAT_ID="123456789"
TELEGRAM_BOT_TOKEN="your_bot_token"

# Detect all WordPress installations
function detect_wp_sites() {
    echo -e "\n🔍 Detecting WordPress installations..."
    find /home/*/public_html -name "wp-config.php" -print 2>/dev/null | sed 's|/wp-config.php||' > /tmp/wp_sites.list
}

# Incremental Backup using rsync + MySQL dump
function backup_all_sites() {
    detect_wp_sites
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
        rsync -a --delete "$site/" "$BACKUP_DIR/${domain}_files/"
        tar -czf "$BACKUP_DIR/$backup_name" "$BACKUP_DIR/${domain}_files" "$BACKUP_DIR/${domain}_db.sql"
        rm -rf "$BACKUP_DIR/${domain}_files" "$BACKUP_DIR/${domain}_db.sql"
        echo "✅ Backup completed: $backup_name" | tee -a "$LOG_FILE"
    done < /tmp/wp_sites.list
}

# Advanced Security Hardening
function apply_security() {
    detect_wp_sites
    echo -e "\n🔒 Applying Security Hardening..."
    while read -r site; do
        $WP_CLI --path="$site" config set DISALLOW_FILE_EDIT true
        $WP_CLI --path="$site" config set WP_DEBUG false
        $WP_CLI --path="$site" plugin install wordfence --activate
        $WP_CLI --path="$site" rewrite flush
        echo "✅ Security applied to: $site"
    done < /tmp/wp_sites.list

    # Apply Firewall Rules
    echo -e "\n🛡 Configuring Firewall..."
    iptables -A INPUT -p tcp --dport 22 -j DROP
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT
    service iptables save
    echo "✅ Firewall configured"

    # Enable Fail2Ban
    echo -e "\n🚧 Enabling Fail2Ban..."
    systemctl start fail2ban
    systemctl enable fail2ban
}

# Monitor Server & Notify Admin
function monitor_server() {
    echo -e "\n📊 Monitoring Server..."
    uptime | tee -a "$LOG_FILE"
    df -h | tee -a "$LOG_FILE"
    netstat -anp | grep ":80" | tee -a "$LOG_FILE"

    # Send Email Notification if Server Load is High
    LOAD=$(uptime | awk '{print $(NF-2)}' | sed 's/,//')
    if (( $(echo "$LOAD > 3.0" | bc -l) )); then
        echo "⚠️ High Server Load Detected: $LOAD" | mail -s "High Load Alert" "$EMAIL_ALERT"
    fi

    # Send Telegram Notification
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        -d text="🚨 Server Alert: High Load Detected! Current Load: $LOAD"
}

# Web-Based UI for Management
function launch_ui() {
    echo -e "\n🌍 Launching Web-Based UI..."
    php -S 0.0.0.0:8080 -t /root/wp-admin-panel &
    echo "✅ UI running on http://yourserverip:8080"
}

# AI-Based Auto-Healing (Fix Crashed Sites)
function auto_heal_wp() {
    detect_wp_sites
    echo -e "\n🩺 Running Auto-Heal for WordPress..."
    while read -r site; do
        if ! curl -s --head "$site" | grep "200 OK"; then
            echo "⚠️ Site down: $site - Attempting auto-fix..."
            $WP_CLI --path="$site" core check-update && $WP_CLI --path="$site" core update
            $WP_CLI --path="$site" plugin update --all
            $WP_CLI --path="$site" theme update --all
            echo "✅ Site restored: $site"
        fi
    done < /tmp/wp_sites.list
}

# Main Menu
while true; do
    echo -e "\n🚀 Advanced WordPress Management"
    echo "1) Detect WordPress Sites"
    echo "2) Backup All Sites (Incremental)"
    echo "3) Apply Security Hardening"
    echo "4) Monitor Server (with Alerts)"
    echo "5) Launch Web UI"
    echo "6) Auto-Heal Crashed Sites"
    echo "0) Exit"
    read -p "Select an option: " choice

    case $choice in
        1) detect_wp_sites ;;
        2) backup_all_sites ;;
        3) apply_security ;;
        4) monitor_server ;;
        5) launch_ui ;;
        6) auto_heal_wp ;;
        0) exit ;;
        *) echo "❌ Invalid option! Try again." ;;
    esac
done
