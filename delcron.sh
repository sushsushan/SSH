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
  # If there are existing cron jobs, display a list of them and ask the user which one they want to delete
  echo "Here are the existing cron jobs:"
  echo "$existing_crons" | nl
  read -p "Which cron job would you like to delete? Enter the number: " cron_number


  # Use the selected number to retrieve the corresponding cron job
  selected_cron=$(echo "$existing_crons" | sed -n ${cron_number}p)


  # Confirm with the user if they want to delete the selected cron job
  echo "You have selected the following cron job to delete:"
  echo "$selected_cron"
  read -p "Are you sure you want to delete this cron job? (y/n)" delete_cron


  if [ "$delete_cron" == "y" ]; then
    # Remove the selected cron job from the crontab
    (crontab -l | grep -v -F "$selected_cron") | crontab -


    # Display a message to confirm the cron job has been deleted
    echo "The cron job has been deleted."
  else
    # If the user does not want to delete the cron job, exit the script
    exit 0
  fi
fi
