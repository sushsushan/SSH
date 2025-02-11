#!/bin/bash


echo "
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃              Welcome to the world of cron jobs!            ┃
┃     A cron job is a scheduled task that runs automatically ┃ 
┃           on your server. It's a powerful tool for         ┃
┃          automating repetitive tasks, such as backups      ┃
┃                 or sending email notifications.            ┃
┃                                                            ┃
┃          Here's an example of a cron job entry that        ┃
┃              runs a command every day at midnight:         ┃
┃                                                            ┃
┃           0 0 * * * /path/to/command                       ┃
┃                                                            ┃
┃     This entry specifies that the command should run at    ┃
┃     minute 0 and hour 0 (midnight) every day.              ┃
┃                                                            ┃
┃    To write your own cron job entry, you'll need to        ┃
┃    understand the format of the crontab file, which        ┃
┃    consists of five fields for minute, hour, day of the    ┃
┃    month, month, and day of the week. Here's a quick       ┃
┃    cheat sheet:                                            ┃
┃                                                            ┃
┃        *     any value                                     ┃
┃        ,     separate values                               ┃
┃        -     range of values                               ┃
┃        /     step values                                   ┃
┃                                                            ┃
┃    For example, the following entry would run a command    ┃
┃    every 30 minutes:                                       ┃
┃                                                            ┃
┃        */30 * * * * /path/to/command                       ┃
┃                                                            ┃
┃    To learn more about cron jobs and how to write cron     ┃
┃    job entries, check out the 'crontab' man page or        ┃
┃    online resources such as CronGuru.                      ┃
┃                                                            ┃
┃                      Happy scheduling!                     ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
"


# Check if there are any existing cron jobs
crontab -l &>/dev/null
if [[ $? -eq 0 ]]; then
  # Show current cron jobs in a user-friendly format
  echo "Current cron jobs:"
  echo "----------------------------------------"
  crontab -l | sed 's/\s\+/ /g' | sed '/^#/d' | sed '/^SHELL=/d' | while read line; do
    if [[ -n "$line" ]]; then
      echo -e "${line// /\t\t}\n"
    fi
  done
  echo "----------------------------------------"
else
  echo "There are no cron jobs created yet."
  read -p "Would you like to create one? (y/n) " create_cron_job
  if [[ "$create_cron_job" == "y" ]]; then
    # Redirect to newcron.sh
    ./newcron.sh
  else
    echo "Exiting Cron Job..."
    exit 0
  fi
fi


# Display options to the user
echo ""
echo "What would you like to do?"
echo "1. Create new cron job"
echo "2. Edit existing cron job"
echo "3. Delete cron job"
echo "4. Test if cron job is running or not"
echo "5. Exit"


read choice


case $choice in
  1)
    # Redirect to newcron.sh
    ./newcron.sh
    ;;
  2)
    # Redirect to editcron.sh
    ./editcron.sh
    ;;
  3)
    # Redirect to delcron.sh
    ./delcron.sh
    ;;
  4)
    # Redirect to testcron.sh
    ./testcron.sh
    ;;
  5)
    # Exit the script
    echo "Exiting Cron Job..."
    exit 0
    ;;
  *)
    echo "Invalid choice"
    exit 1
    ;;
esac
