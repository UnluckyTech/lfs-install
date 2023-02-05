#!/bin/bash

while true
do
    echo ''
    echo '*********************************'
    echo '********* LFS  TempTools ********'
    echo '*********************************'
    echo '1. Packages and Patches'
    echo '2. IDK'
    echo '3. IDK'
    echo '4. IDK'
    echo '5. Return to Installer'
    read option
    if [[ $option == "1" ]]; then
        echo "Creating Directory and Setting Permission's"
        sleep 1
        mkdir -v $LFS/sources
        chmod -v a+wt $LFS/sources
        echo "Fetching Required Packages"
        sleep 1
        wget -P $LFS/sources https://www.linuxfromscratch.org/lfs/view/stable/wget-list-sysv
        wget --input-file=wget-list-sysv --continue --directory-prefix=$LFS/sources
        echo "Verifying Packages"
        wget -P $LFS/sources https://www.linuxfromscratch.org/lfs/view/stable/md5sums

    elif [[ $option == "2" ]]; then
        echo 'nuh'
    elif [[ $option == "3" ]]; then 
        echo 'nuh'
    elif [[ $option == "4" ]]; then
        echo 'nuh'
    elif [[ $option == "5" ]]; then
        . main.sh
    else
        2>/dev/null
        echo 'Incorrect command. Try again.'
    fi
        
done

