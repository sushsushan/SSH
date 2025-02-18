#!/bin/bash

while true; do
  clear
  echo " __          __  _                            _           "
  echo " \ \        / / | |                          | |          "
  echo "  \ \  /\  / /__| | ___ ___  _ __ ___   ___  | |_ ___     "
  echo "   \ \/  \/ / _ \ |/ __/ _ \| '_ \` _ \ / _ \ | __/ _ \   "
  echo "    \  /\  /  __/ | (_| (_) | | | | | |  __/ | || (_) |  "
  echo "     \/  \/ \___|_|\___\___/|_| |_| |_|\___|  \__\___/   "
  echo " "
  echo "Welcome to our Advanced Bash tool!"
  echo "Choose a tool from the options below:"
  echo ""
  echo "      +---------+----------------------+"
  echo "      | Option  | Tool                 |"
  echo "      +---------+----------------------+"
  echo "      | 1       | File Manager         |"
  echo "      | 2       | Php                  |"
  echo "      | 3       | WordPress            |"
  echo "      | 4       | Database             |"
  echo "      | 5       | CronJob              |"
  echo "      | 6       | Emails               |"
  echo "      | 7       | TOS/Malware Scanner  |"
  echo "      | 8       | Others               |"
  echo "      | 9       | System Info          |"
  echo "      | 10      | Network Diagnostics  |"
  echo "      | 11      | Security Audit       |"
  echo "      | 12      | Server Monitoring    |"
  echo "      | 13      | Advanced Backup      |"
  echo "      | 14      | Logs Viewer          |"
  echo "      | 15      | Main Home Page       |"
  echo "      +---------+----------------------+"
  echo ""

  read -p "Please choose an option (1-15): " choice

  # Function to fetch and execute an external script
  execute_remote_script() {
    local script_name=$1
    local script_url=$2
    
    curl -sS -o "$script_name" "$script_url"
    chmod +x "$script_name"
    ./"$script_name" || echo "Error: Failed to execute $script_name."
  }

  case $choice in
    1) execute_remote_script "fm.sh" "https://example.com/scripts/fm.sh" ;;
    2) execute_remote_script "php.sh" "https://example.com/scripts/php.sh" ;;
    3) execute_remote_script "wp.sh" "https://example.com/scripts/wp.sh" ;;
    4) execute_remote_script "db.sh" "https://example.com/scripts/db.sh" ;;
    5) execute_remote_script "cron.sh" "https://example.com/scripts/cron.sh" ;;
    6) execute_remote_script "emails.sh" "https://example.com/scripts/emails.sh" ;;
    7) execute_remote_script "tos_malware.sh" "https://example.com/scripts/tos_malware.sh" ;;
    8) execute_remote_script "other.sh" "https://example.com/scripts/other.sh" ;;
    9) execute_remote_script "system_info.sh" "https://example.com/scripts/system_info.sh" ;;
    10) execute_remote_script "network_diag.sh" "https://example.com/scripts/network_diag.sh" ;;
    11) execute_remote_script "security_audit.sh" "https://example.com/scripts/security_audit.sh" ;;
    12) execute_remote_script "server_monitor.sh" "https://example.com/scripts/server_monitor.sh" ;;
    13) execute_remote_script "backup.sh" "https://example.com/scripts/backup.sh" ;;
    14) execute_remote_script "logs_viewer.sh" "https://example.com/scripts/logs_viewer.sh" ;;
    15) execute_remote_script "home.sh" "https://raw.githubusercontent.com/sushsushan/SSH/refs/heads/main/meta_tool.sh" ;;
    *)
      echo "Invalid input. Please enter a number between 1 and 15."
      ;;
  esac

  read -p "Press Enter to continue..."
done
