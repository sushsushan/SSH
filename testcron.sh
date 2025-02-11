#!/bin/bash


echo "Welcome to cron tester"


# Get the current user's home directory
homedir=$(eval echo ~$USER)


# Create a cron job to touch the temporary file every minute
(crontab -l ; echo "* * * * * touch $homedir/tempfile") | crontab - > /dev/null 2>&1


# Wait for the cron job to run and check if the tempfile has been created
counter=0
while [ $counter -lt 3 ]; do
    if [ -f $homedir/tempfile ]; then
        echo Cron job is working
        rm $homedir/tempfile
        # Remove the cron job that touches the temporary file
        crontab -l | grep -v "touch $homedir/tempfile" | crontab - > /dev/null 2>&1
        exit 0
    fi
    counter=$((counter+1))
    countdown=$((3-counter))
    echo "Testing testing ... $countdown minute(s) remaining"
    sleep 60
done


echo Cron job is not running
