#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'

########################################################################################################
# Variables globales
########################################################################################################

## Carga configuracion
source /etc/Hermes.conf

## Nombre del script
scriptName=$(basename -- "$0")

TOKEN="$token"
ID="$id"
URL="https://api.telegram.org/bot${TOKEN}/sendMessage"

file_shadow="/etc/shadow"

shadow_filter="/tmp/${scriptName%.sh}_filter"
shadow_differ="/tmp/${scriptName%.sh}_differ"

########################################################################################################
# Funciones
########################################################################################################

########################################################################################################
# Filtra usuarios y contraseñas de archivo shadow, evita filtrar campos con ! o * en la seccion de contraseñas
########################################################################################################
filtra_shadow() {

    if ! awk 'BEGIN { FS=":";OFS="|"} $2!~/[*!]/ {print $1,$2}' "$file_shadow" > "$1"; then
        return 1
    fi

    return 0

}


send_message() {

    #echo "curl -s $URL -d chat_id=$ID -d text=$1"

    if ! curl -s "$URL" -d chat_id="$ID" -d text="$1"; then
        return 1
    fi

    return 0

}

########################################################################################################
# Main
########################################################################################################

## Obtiene usuarios relevantes
filtra_shadow "$shadow_filter"

if [[ -n "$TOKEN" && -n "$ID" ]]; then

    ## Se monitorea archivo shadow
    while inotifywait -q -e attrib "$file_shadow"; do

        ## Obtiene usuarios relevantes despues de un evento en shadow
        filtra_shadow "$shadow_differ"

        ## Filtra usuarios con diferencias en sus contraseña encriptada
        usuarios=$(grep -vFxf "$shadow_filter" "$shadow_differ" | awk -F "|" '{print $1}' || true)
   
        ## Si no obtuvo diferencia
        if [[ -z "$usuarios" ]]; then
            continue
        fi

        ## Itera sobre cada usuario obtenido 
        while read -r user; do

            if awk -F "|" '{print $1}' "$shadow_filter" | grep -q "$user"; then
                mensaje="El usuario '$user' cambio su contraseña"
            else
                mensaje="Se establecio contraseña a usuario '$user'"
            fi

            send_message "$mensaje" || echo "Fallo al mandar mensaje por telegram"
            printf "\n%s\n " "$mensaje"

        done <<< "$usuarios"

        ## Obtiene usuarios relevantes
        filtra_shadow "$shadow_filter"

    done

else
    printf "\n%s\n" "Credenciales vacías"
    exit 1
fi

exit 0
