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
  echo "Welcome to our Bash tool!"
  echo "Choose a tool from the options below:"
  echo ""
  echo "      +---------+----------------+"
  echo "      | Option  | Tool           |"
  echo "      +---------+----------------+"
  echo "      | 1       | File Manager   |"
  echo "      | 2       | Php            |"
  echo "      | 3       | WordPress      |"
  echo "      | 4       | Database       |"
  echo "      | 5       | CronJob        |"
  echo "      | 6       | Emails         |"
  echo "      | 7       | TOS/Malware    |"
  echo "      | 8       | Others         |"
  echo "      | 9       | Main Home Page |"
  echo "      +---------+----------------+"
  echo ""

  read -p "Please choose an option (1-9): " choice

  case $choice in
    1) 
      if [ -x "./fm.sh" ]; then
        ./fm.sh
      else
        echo "Error: File Manager script not found or not executable."
      fi
      ;;
    2) 
      if [ -x "./php.sh" ]; then
        ./php.sh
      else
        echo "Error: Php script not found or not executable."
      fi
      ;;
    3) 
      if [ -x "./wp.sh" ]; then
        ./wp.sh
      else
        echo "Error: WordPress script not found or not executable."
      fi
      ;;
    4) 
      if [ -x "./db.sh" ]; then
        ./db.sh
      else
        echo "Error: Database script not found or not executable."
      fi
      ;;
    5) 
      if [ -x "./cron.sh" ]; then
        ./cron.sh
      else
        echo "Error: CronJob script not found or not executable."
      fi
      ;;
    6) 
      if [ -x "./emails.sh" ]; then
        ./emails.sh
      else
        echo "Error: Emails script not found or not executable."
      fi
      ;;
    7) 
      if [ -x "./tos_malware.sh" ]; then
        ./tos_malware.sh
      else
        echo "Error: TOS/Malware script not found or not executable."
      fi
      ;;
    8) 
      if [ -x "./other.sh" ]; then
        ./other.sh
      else
        echo "Error: Other script not found or not executable."
      fi
      ;;
    9)
      # Redirect to Main Home Page
      if [ -x "./home.sh" ]; then
        ./home.sh
      else
        echo "Error: Main Home Page script not found or not executable."
      fi
      ;;
    *)
      echo "Invalid input. Please enter a number between 1 and 9."
      ;;
  esac

  read -p "Press Enter to continue..."
done

