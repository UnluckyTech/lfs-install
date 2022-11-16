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
    echo '1. Configure VM'
    echo '2. Enter Root'
    echo '3. Check Prerequisites'
    echo '4. Partition Drive'

    read option 
    if [[ $option == "1" ]]; then
        echo 'y' | sudo pacman -S rxvt-unicode
        sudo systemctl start sshd
        ip= ifconfig | grep "inet "|awk '{print $2}'
        echo "You can now SSH. Here are your local IPs"
        echo "$ip"
        echo "ssh -p 2222 liveuser@ip"
        echo "liveuser pass: root"
        if [ "$EUID" -ne 0 ]
            then echo "Please run as root"
            
        fi
    elif [[ $option == "2" ]]; then
        echo "WARNING: You will need to rerun the script"
        echo "Here is your current path:"
        echo "$PATH"
        sleep 3
        ( echo 'root' ; echo 'root' ) | passwd
        sudo su -


    elif [[ $option == "3" ]]; then 
        . prereq.sh
    elif [[ $option == "4" ]]; then
        fdisk -l
        echo "What drive are we working with?"
        read device
        echo "Are you sure you want to format $device ? [y/n]"
        read erase
        if [[ $erase == "y" ]]; then
        ( echo 'G' ; echo 'w' ) | fdisk "$device"
        echo "Will now partition the drive"
        ( echo 'n' ; echo 'p' ; echo '1' ; echo '2048' ; echo '+1G' ; echo 't' ; echo '82' ; echo 'p' ; echo '2' ; echo '' ; echo '' ; echo 'w' ) | fdisk "$device"
        fdisk -l
        echo "for drive $device you should see 2 partitions "
        sleep 3
        elif [[ $erase == "n" ]]; then
        echo "Returning to Menu"
        fi
        

    else
        2>/dev/null
        echo 'Incorrect command. Try again.'
    fi
done
