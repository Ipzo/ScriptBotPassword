#!/bin/bash


TOKEN=
ID=
URL"https://api.telegram.org/bot$TOKEN/sendMessage"

cat /etc/shadow > /root/tmp/Passwords


while inotifywait -e /etc/shadow; do

cat /etc/shadow > /root/tmp/PasswordsTemporal
mensaje=$(diff /root/tmp/Passwords /root/bot/PasswordsTemporal | tail -1 | awk -F: '{print $1}')
cat /etc/shadow > /root/bot/Passwords
curl -s -X POST $URL -d chat_id=$ID -d text="El usuario $mensaje cambio su contraseña"
