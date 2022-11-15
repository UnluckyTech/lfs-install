#!/bin/bash
while true
do

    echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    echo '%%%%%%%%% LFS  Installer %%%%%%%%'
    echo '%%%% Choose how you want to  %%%%'
    echo '%%%%%%%%%%%% begin %%%%%%%%%%%%%%'
    echo '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'
    echo ''
    echo '1. Check Prerequisites'
    echo '2. Partition'

    read option 

    if [[ $option == "1" ]]; then 
        . prereq.sh
    elif [[ $option == "2" ]]; then
    fdisk -l
    else
        2>/dev/null
        echo 'Incorrect command. Try again.'
    fi
done
