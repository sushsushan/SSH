#!/bin/bash
# AI-Powered WordPress Management Script
# Features: Security Fixes, Optimization, Backup & Restore, WP-CLI Automation

# Define WordPress Directory Root (Modify as needed)
WP_ROOT="/home/$USER/public_html"
LOG_FILE="/var/log/wp_manager.log"
BACKUP_DIR="/home/$USER/wp_backups"

# Ensure WP-CLI is installed
if ! command -v wp &> /dev/null; then
    echo "WP-CLI not found. Installing..."
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# Function: Scan for WordPress installations
detect_wp_sites() {
    find "$WP_ROOT" -name "wp-config.php" | while read -r config;
    do
        echo "Found WordPress site: $(dirname "$config")"
    done
}

# Function: Backup WordPress sites
backup_wp() {
    mkdir -p "$BACKUP_DIR"
    detect_wp_sites | while read -r site;
    do
        site_name=$(basename "$site")
        tar -czf "$BACKUP_DIR/${site_name}_backup.tar.gz" "$site"
        wp db export "$BACKUP_DIR/${site_name}_db.sql" --path="$site"
        echo "Backup completed for $site"
    done
}

# Function: Update WordPress, Plugins, and Themes
update_wp() {
    detect_wp_sites | while read -r site;
    do
        echo "Updating WordPress at $site..."
        wp core update --path="$site"
        wp plugin update --all --path="$site"
        wp theme update --all --path="$site"
        echo "Update completed for $site"
    done
}

# Function: Optimize Database
optimize_db() {
    detect_wp_sites | while read -r site;
    do
        echo "Optimizing database for $site..."
        wp db optimize --path="$site"
    done
}

# Function: Fix File Permissions
fix_permissions() {
    detect_wp_sites | while read -r site;
    do
        echo "Fixing file permissions for $site..."
        find "$site" -type d -exec chmod 755 {} \;
        find "$site" -type f -exec chmod 644 {} \;
    done
}

# Function: Check Site Health
check_site_health() {
    detect_wp_sites | while read -r site;
    do
        echo "Checking site health for $site..."
        wp doctor check --path="$site"
    done
}

# Function: Display Usage Instructions
usage() {
    echo "Usage: $0 {backup|update|optimize|fix|health}"
    exit 1
}

# Main Execution
if [ $# -eq 0 ]; then
    usage
fi

case "$1" in
    backup)
        backup_wp
        ;;
    update)
        update_wp
        ;;
    optimize)
        optimize_db
        ;;
    fix)
        fix_permissions
        ;;
    health)
        check_site_health
        ;;
    *)
        usage
        ;;
esac
