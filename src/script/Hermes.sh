#!/bin/bash

# -e <event>		Listen for specific event(s) only

source /etc/Hermes.conf


TOKEN=$token
ID=$id
URL="https://api.telegram.org/bot$TOKEN/sendMessage"

cat /etc/shadow > /tmp/Passwords

if [[! -z "$TOKEN"]] && [[! -z "$ID"]];
then
    while inotifywait -e /etc/shadow; do

    cat /etc/shadow > /tmp/PasswordsTemporal
    mensaje=$(diff /tmp/Passwords /tmp/PasswordsTemporal | tail -1 | awk -F: '{print $1}')
    cat /etc/shadow > /tmp/Passwords
    curl -s -X POST $URL -d chat_id=$ID -d text="El usuario $mensaje cambio su contraseña"
    echo "El usuario $mensaje cambio su contraseña"
done
fi
