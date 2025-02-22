#!/bin/bash

# Simulate the uapi output (replace this with your actual command or use output redirection)
uapi_output="documentroot: /home4/umvavtmy/test.umv.avt.mybluehost.me
domain: test.umv.avt.mybluehost.me
group: umvavtmy
hascgi: 1
homedir: /home4/umvavtmy
ip: 162.241.224.38
ipv6: ~
no_cache_update: 0
owner: root
phpopenbasedirprotect: 1
serveradmin: webmaster@test.umv.avt.mybluehost.me
serveralias: www.test.umv.avt.mybluehost.me
servername: test.umv.avt.mybluehost.me
status: not redirected
type: sub_domain
usecanonicalname: 'Off'
user: umvavtmy
userdirprotect: ''"

# Extract necessary fields using grep and awk
ip=$(echo "$uapi_output" | grep -i "ip" | awk -F': ' '{print $2}')
homedir=$(echo "$uapi_output" | grep -i "homedir" | awk -F': ' '{print $2}')
serveradmin=$(echo "$uapi_output" | grep -i "serveradmin" | awk -F': ' '{print $2}')
serveralias=$(echo "$uapi_output" | grep -i "serveralias" | awk -F': ' '{print $2}')
servername=$(echo "$uapi_output" | grep -i "servername" | awk -F': ' '{print $2}')
user=$(echo "$uapi_output" | grep -i "user" | awk -F': ' '{print $2}')

# Header for the main information
echo "Main Information:"
echo "-------------------"
echo "IP: $ip"
echo "Homedir: $homedir"
echo "serveradmin: $serveradmin"
echo "serveralias: $serveralias"
echo "servername: $servername"
echo "user: $user"
echo ""

# Header for additional details
echo "Details:"
echo "-------------------"
domain=$(echo "$uapi_output" | grep -i "domain" | awk -F': ' '{print $2}')
type=$(echo "$uapi_output" | grep -i "type" | awk -F': ' '{print $2}')
documentroot=$(echo "$uapi_output" | grep -i "documentroot" | awk -F': ' '{print $2}')
userdirprotect=$(echo "$uapi_output" | grep -i "userdirprotect" | awk -F': ' '{print $2}')

# Display the additional information
echo "Domain: $domain"
echo "Type: $type"
echo "Documentroot: $documentroot"
echo "userdirprotect: $userdirprotect"

