#!/bin/bash


# Fetch the cPanel username
user=$(whoami)


# Ask the user if they want to regenerate the shadow file
read -p "Regenerate shadow file for all email accounts? [y/n]: " choice


if [[ $choice =~ ^[Yy]$ ]]; then


  if [[ -d /home/$user/mail ]]; then


    uid=$(id -u $user)
    gid=$(id -g $user)
    change=0


    for file in /home/$user/etc/*/{shadow,passwd}; do
      cp -a $file{,.$(date +%s)}
    done


    check() {
      etc="/home/$user/etc/$domain/$1"


      if [[ ! -f $etc ]]; then
        su - $user -c "mkdir -p ${etc%/*} ; touch $etc"
        echo "Recreated $etc"
      fi


      if ! grep "^$acct:" $etc 1>/dev/null; then
        if [[ $1 = 'passwd' ]]; then
          echo "$acct:x:$uid:$gid::/home/$user/mail/$domain/$acct:/home/$user" >>$etc
        else
          echo "$acct:\$1\$$(openssl rand -base64 30):18354::::::" >>$etc
        fi
        echo "Recreated $1 entry for $acct@$domain"
        change=$((change + 1))
      fi
    }


    while read maildir; do
      domain=$(cut -d '/' -f5 <<<"$maildir")
      acct=$(cut -d '/' -f6 <<<"$maildir")
      check passwd
      check shadow


    done < <(find /home/$user/mail -maxdepth 2 -mindepth 2 -user $user -type d -regextype posix-awk ! -regex '/.*/(new|cur|tmp|.*\.([0-9]{8,}|ba?k|old)$)')


    if [[ $change -lt 1 ]]; then
      echo "No changes made"
    fi


  else
    echo "Mail directory /home/$user/mail does not exist"
  fi


else
  echo "Skipping shadow file regeneration."
fi
