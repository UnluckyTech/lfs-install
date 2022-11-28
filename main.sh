#!/bin/bash
while true
do
    echo ''
    echo 'PLEASE LOOK AT README.md BEFORE USING THIS'
    echo 'Loading...'
    sleep 1
    clear
    echo ''
    echo '*********************************'
    echo '********* LFS  Installer ********'
    echo '*********************************'
    echo '1. Preparing for the Build'
    echo '2. Building LFS Cross Toolchain & Temp Tools'
    echo '3. Building the LFS System'
    echo '4. Documentation'
    echo '5. Exit'
    read option
    if [[ $option == "1" ]]; then
        . prepare.sh
    elif [[ $option == "2" ]]; then
        . temptools.sh
    elif [[ $option == "3" ]]; then 
        . buildlfs.sh
    elif [[ $option == "4" ]]; then
        . docs.sh
    elif [[ $option == "5" ]]; then
        exit
    else
        2>/dev/null
        echo 'Incorrect command. Try again.'
    fi
        
done
