#!/bin/bash

# Fetching system details
USER=$(whoami)
SERVER=$(hostname)
clear

read -p "Enter domain name: " DOMAIN

echo -e "\n\e[1;33mChoose an option:\e[0m"
echo "1) Confirm files"
echo "2) View file"
echo "3) Restore website"
echo "4) Restore database"
echo "5) Full restore"
read -p "Enter your choice: " OPTION

case $OPTION in
    1)
        read -p "Enter path: " PATH
        read -p "Is it archived? (y/n): " ARCHIVED
        if [[ "$ARCHIVED" == "y" ]]; then
            read -p "Enter partition number: " PARTITION
            ARCHIVED_FLAG="--archived --partition=$PARTITION"
        fi
        RESULT_COMMANDS=(
            "dclistfiles $USER daily $SERVER $PATH $ARCHIVED_FLAG"
            "dclistfiles $USER weekly $SERVER $PATH $ARCHIVED_FLAG"
            "dclistfiles $USER monthly $SERVER $PATH $ARCHIVED_FLAG"
        )
        ;;
    2)
        read -p "Enter file path (e.g., public_html/wp-config.php): " FILE_PATH
        RESULT_COMMANDS=(
            "dcviewfile $USER $SERVER daily $FILE_PATH"
            "dcviewfile $USER $SERVER weekly $FILE_PATH"
            "dcviewfile $USER $SERVER monthly $FILE_PATH"
        )
        ;;
    3)
        read -p "Enter path to restore: " PATH
        read -p "Ignore existing files? (y/n): " IGNORE
        if [[ "$IGNORE" == "y" ]]; then
            IGNORE_FLAG="--ignore-existing"
        else
            read -p "Exclude any folders? (comma-separated, e.g., test,demo): " EXCLUDE
            [[ -n "$EXCLUDE" ]] && EXCLUDE_FLAG="--exclude={'$EXCLUDE'}"
        fi
        read -p "Is it archived? (y/n): " ARCHIVED
        if [[ "$ARCHIVED" == "y" ]]; then
            read -p "Enter partition number: " PARTITION
            ARCHIVED_FLAG="--archived --partition=$PARTITION"
        fi
        read -p "Notify email? (leave empty for none): " NOTIFY
        [[ -n "$NOTIFY" ]] && NOTIFY_FLAG="--notify=$NOTIFY"
        RESULT_COMMANDS=(
            "dcrestorepath $USER $SERVER daily $PATH $IGNORE_FLAG $EXCLUDE_FLAG $ARCHIVED_FLAG $NOTIFY_FLAG"
            "dcrestorepath $USER $SERVER weekly $PATH $IGNORE_FLAG $EXCLUDE_FLAG $ARCHIVED_FLAG $NOTIFY_FLAG"
            "dcrestorepath $USER $SERVER monthly $PATH $IGNORE_FLAG $EXCLUDE_FLAG $ARCHIVED_FLAG $NOTIFY_FLAG"
        )
        ;;
    4)
        read -p "Enter database name: " DBNAME
        read -p "Is it archived? (y/n): " ARCHIVED
        if [[ "$ARCHIVED" == "y" ]]; then
            read -p "Enter partition number: " PARTITION
            ARCHIVED_FLAG="--archived --partition=$PARTITION"
        fi
        RESULT_COMMANDS=(
            "dcrestoremysqldb $USER $SERVER daily $DBNAME $ARCHIVED_FLAG"
            "dcrestoremysqldb $USER $SERVER weekly $DBNAME $ARCHIVED_FLAG"
            "dcrestoremysqldb $USER $SERVER monthly $DBNAME $ARCHIVED_FLAG"
        )
        ;;
    5)
        read -p "Is it archived? (y/n): " ARCHIVED
        if [[ "$ARCHIVED" == "y" ]]; then
            read -p "Enter partition number: " PARTITION
            ARCHIVED_FLAG="--archived --partition=$PARTITION"
        fi
        read -p "Notify email? (leave empty for none): " NOTIFY
        [[ -n "$NOTIFY" ]] && NOTIFY_FLAG="--notify=$NOTIFY"
        RESULT_COMMANDS=(
            "dcfulldatarestore $USER daily $SERVER $ARCHIVED_FLAG $NOTIFY_FLAG"
            "dcfulldatarestore $USER weekly $SERVER $ARCHIVED_FLAG $NOTIFY_FLAG"
            "dcfulldatarestore $USER monthly $SERVER $ARCHIVED_FLAG $NOTIFY_FLAG"
            "dcbackuprestore $USER daily $SERVER"
            "dcbackuprestore $USER weekly $SERVER"
            "dcbackuprestore $USER monthly $SERVER"
            "dcbackuprestore $USER latam $SERVER"
        )
        ;;
    *)
        echo -e "\e[1;31mInvalid option!\e[0m"
        exit 1
        ;;
esac

clear
# Display system and backup details before results
echo -e "\e[1;34mUser:\e[0m $USER"
echo -e "\e[1;34mServer:\e[0m $SERVER"
echo -e "\n\e[1;32mInitial Commands:\e[0m"
echo "checkbackupbh $USER $SERVER"
echo "checkbackuphg $DOMAIN [$SERVER]"
echo "dcbackuplist $USER $SERVER"
echo "skipbackup $USER $SERVER next"

# Display generated commands
echo -e "\n\e[1;32mGenerated commands:\e[0m"
for cmd in "${RESULT_COMMANDS[@]}"; do
    echo "$cmd"
done
