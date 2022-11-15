#!/bin/bash
while true
do

    echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    echo '%%%%%%%%% LFS  Installer %%%%%%%%'
    echo '%%%% Choose how you want to  %%%%'
    echo '%%%%%%%%%%%% begin %%%%%%%%%%%%%%'
    echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    echo ''
    echo '1. Configure VM'
    echo '2. Check Prerequisites'
    echo '3. Partition Drive'

    read option 

    if [[ $option == "1" ]]; then
        sudo pacman -S rxvt-unicode
        sudo systemctl start sshd
        if [ "$EUID" -ne 0 ]
            then echo "Please run as root"
            exit
        fi
    elif [[ $option == "2" ]]; then 
        . prereq.sh
    elif [[ $option == "3" ]]; then
    fdisk -l
    else
        2>/dev/null
        echo 'Incorrect command. Try again.'
    fi
done
