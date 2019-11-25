#!/bin/bash

NameScript="BotCambioDeContrasena.sh"
NameService="Hermesd"
NameConfig="Hermesd.conf"


install_service()
{
    echo Copying files..
    cp src/config/$NameConfig /etc
    cp src/script/$NameScript /usr/sbin
    cp src/service/$NameService /etc/init.d

    echo Making directories..
    mkdir /var/log/Hermes

    chown root:root /etc/$NameConfig 
    chown root:root /usr/sbin/$NameScript
    chown root:root /etc/init.d/$NameService
    chown root:root /var/log/Hermes
   
    echo Adding permissions..
    chmod 644 /etc/$NameConfig 
    chmod 755 /usr/sbin/$NameScript
    chmod 755 /etc/init.d/$NameService
    chmod 755 /var/log/Hermes
    
    echo Adding service..
    chkconfig --add /etc/init.d/$NameService
    chkconfig --level 2345 $NameService on

    service $NameService start
    service $NameService status
}

    uninstall_service()
{
    service $NameService stop 

    echo Removing service.. 
    chkconfig $NameService off
    chkconfig --del $NameService

    echo Removing files..
    rm -f /etc/init.d/inotify-cho
    rm -f /usr/sbin/$NameScript
    rm -f /etc/$NameConfig 
    rm -f /var/log/Hermes/Hermes.log
    rm -f /var/log/Hermes/Hermes.err

    echo Removing directories..
    rmdir /var/log/Hermes

    echo Done
}

reinstall_service()
{
    service $NameService stop 

    echo Removing service.. 
    chkconfig $NameService off
    chkconfig --del $NameService

    echo Removing files..
    rm -f /etc/init.d/$NameService
    rm -f /usr/sbin/$NameScript

    echo Copying files..
    cp src/script/$NameScript /usr/sbin
    cp src/service/$NameService /etc/init.d

    chown root:root /usr/sbin/$NameScript
    chown root:root /etc/init.d/$NameService

    echo Adding permissions..
    chmod 755 /usr/sbin/$NameScript
    chmod 755 /etc/init.d/$NameService

    echo Adding service..
    chkconfig --add /etc/init.d/$NameService
    chkconfig --level 2345 $NameService on

    service $NameService start
    service $NameService status
}

PS3='Enter option [1-3]: '

select option in Install Uninstall Reinstall Quit 
do
    case $option in
        "Install")
            echo "Installing.."
            install_service
            break
            ;;
        "Uninstall")
            echo "Uninstalling.."
            uninstall_service
            break
            ;;
        "Reinstall")
            echo "Reinstalling.."
            reinstall_service
            break
            ;;
        "Quit")
            break
            ;;
        *) echo "Invalid option: $REPLY";;
    esac
done
