#!/bin/bash
while true
do
    echo ''
    echo '*********************************'
    echo '******** LFS  Prep Script *******'
    echo '*********************************'
    echo ''    
    echo '1. Configure VM'
    echo '2. Enter Root'
    echo '3. Check Prerequisites'
    echo '4. Partition Drive'
    echo '5. Mount Partitions'
    echo '6. Return to Installer'
    echo ''    
    read option 
    if [[ $option == "1" ]]; then
        sudo pacman -Syy
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
        while true
        do
            echo ''
            echo '1. Configure Root'
            echo '2. Enter Root'
            echo '3. Return to Prep Script'  
            echo ''    
            read input
            if [[ $input == "1" ]]; then
                echo "WARNING: You will need to rerun the script"
                echo "Here is your current path:"
                echo "$PATH"
                sleep 3
                ( echo 'root' ; echo 'root' ) | passwd
                sudo su
                sudo su
            elif [[ $input == "2" ]]; then
                sudo su
                sudo su
            elif [[ $input == "3" ]]; then
                exit
            else
                2>/dev/null
                echo 'Incorrect command. Try again.'
            fi
        done

    elif [[ $option == "3" ]]; then 
        . prereq.sh
    elif [[ $option == "4" ]]; then
        fdisk -l
        echo "What drive are we working with?"
        read device
        echo "Are you sure you want to format $device ? [y/n]"
        read erase
        if [[ $erase == "y" ]]; then
        echo "This will take a minute depending on size."
        shred -n 5 -vz $device
        mkfs.ext4 "$device"
        echo "Will now partition the drive"
        ( echo 'n' ; echo 'p' ; echo '1' ; echo '2048' ; echo '+1G' ; echo 't' ; echo '82' ; echo 'w' ) | fdisk "$device"
        ( echo 'n' ; echo 'p' ; echo '2' ; echo ' ' ; echo ' ' ; echo 'y' ; echo 'w' ) | fdisk "$device"
        mkfs -v -t ext4 ${device}2
        mkswap ${device}1
        fdisk -l
        echo "for drive $device you should see 2 partitions "
        sleep 3
        elif [[ $erase == "n" ]]; then
        echo "Returning to Menu"
        fi
    elif [[ $option == "5" ]]; then
        echo "Creating LFS Variable"
        export LFS=/mnt/lfs
        echo $LFS
        echo "Mounting Partitions"
        mkdir -pv $LFS
        mount -v -t ext4 ${device}2 $LFS
        /sbin/swapon -v ${device}1
        echo "export LFS=/mnt/lfs" >> ~/.bashrc
        source ~/.bashrc
        echo "You will now exit to save the changes"
        exit 0
        
    elif [[ $option == "6" ]]; then
        . main.sh

    else
        2>/dev/null
        echo 'Incorrect command. Try again.'
    fi
done
