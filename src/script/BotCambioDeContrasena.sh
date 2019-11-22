#!/bin/bash

# -e <event>		Listen for specific event(s) only

source /etc/Hermesd.conf


TOKEN=$token
ID=$id
URL"https://api.telegram.org/bot$TOKEN/sendMessage"

cat /etc/shadow > /root/tmp/Passwords

if [ -z "$TOKEN" ] || [ -z "$ID" ]
then
       echo "Token and ID empty, edit config file  Hermesd.conf >&2 "
else
while inotifywait -e /etc/shadow; do

cat /etc/shadow > /root/tmp/PasswordsTemporal
mensaje=$(diff /root/tmp/Passwords /root/bot/PasswordsTemporal | tail -1 | awk -F: '{print $1}')
cat /etc/shadow > /root/bot/Passwords
curl -s -X POST $URL -d chat_id=$ID -d text="El usuario $mensaje cambio su contraseña"
echo "El usuario $mensaje cambio su contraseña"
done
fi
