#!/bin/bash
while true
do

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
        echo 'root' | passwd
        su -

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
