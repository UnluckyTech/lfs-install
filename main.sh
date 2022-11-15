#!/bin/bash
while true
do
    echo 'PLEASE LOOK AT README.md BEFORE USING THIS'
    echo ''
    echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    echo '%%%%%%%%% LFS  Installer %%%%%%%%'
    echo '%%%% Choose how you want to  %%%%'
    echo '%%%%%%%%%%%% begin %%%%%%%%%%%%%%'
    echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    echo ''
    echo '1. Enter Root'
    echo '2. Configure VM'
    echo '3. Check Prerequisites'
    echo '4. Partition Drive'

    read option 
    if [[ $option == "1" ]]; then
        echo "WARNING: You will need to rerun the script"
        echo "Here is your current path:"
        echo "$PATH"
        sleep 3
        ( echo 'root' ; echo 'root' ) | passwd
        sudo su -

    elif [[ $option == "2" ]]; then
        echo 'y' | sudo pacman -S rxvt-unicode --yes
        sudo systemctl start sshd
        if [ "$EUID" -ne 0 ]
            then echo "Please run as root"
            
            exit
        fi
    elif [[ $option == "3" ]]; then 
        . prereq.sh
    elif [[ $option == "4" ]]; then
    fdisk -l
    else
        2>/dev/null
        echo 'Incorrect command. Try again.'
    fi
done
