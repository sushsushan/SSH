#!/bin/bash


echo "Welcome to cron!"


# Get the list of existing cron jobs without MAILTO and SHELL lines
existing_crons=$(crontab -l | grep -v "^MAILTO" | grep -v "^SHELL")


# Check if there are any existing cron jobs
if [ -z "$existing_crons" ]; then
  # If there are no cron jobs, ask the user if they want to create a new one
  read -p "There are no cron jobs. Would you like to create a new one? (y/n)" create_cron


  if [ "$create_cron" == "y" ]; then
    # If the user wants to create a new cron job, redirect them to newcron.sh
    bash newcron.sh
  else
    # If the user does not want to create a new cron job, exit the script
    exit 0
  fi
else
  # If there are existing cron jobs, display a list of them and ask the user which one they want to edit
  echo "Here are the existing cron jobs:"
  echo "$existing_crons" | nl
  read -p "Which cron job would you like to edit? Enter the number: " cron_number


  # Use the selected number to retrieve the corresponding cron job
  selected_cron=$(echo "$existing_crons" | sed -n ${cron_number}p)


  # Allow the user to edit the selected cron job using nano
  echo "You have selected the following cron job:"
  echo "$selected_cron"
  echo ""
  echo "To edit the cron job using nano, press Enter"
  read
  nano_tmp=$(mktemp)
  echo "$selected_cron" > $nano_tmp
  nano $nano_tmp


  # Read the edited cron job from the temporary file
  edited_cron=$(cat $nano_tmp)


  # Validate the edited cron job
  if ! echo "$edited_cron" | crontab -l 2>/dev/null >/dev/null; then
    echo "Error: Invalid cron job format."
    rm $nano_tmp
    exit 1
  fi


  # Update the cron job in the crontab
  (crontab -l | sed "${cron_number}s|.*|$edited_cron|") | crontab -


  # Display the updated cron job to the user
  echo "The cron job has been edited. Here is the updated version:"
  echo "$edited_cron"


  # Remove the temporary file
  rm $nano_tmp
fi
