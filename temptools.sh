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
        echo ''
        echo '*********************************'
        echo '****** Packages and Patches *****'
        echo '*********************************'
        echo '1. Download Packages'
        echo '2. Validate Packages'
        echo '3. Return to TempTools'
        read tpack
        if [[ $tpack == "1" ]]; then
            echo "Creating Directory and Setting Permission's"
            sleep 2
            mkdir -v $LFS/sources
            cd $LFS/sources
            chmod -v a+wt $LFS/sources
            echo "Fetching Required Packages"
            sleep 2
            wget -P $LFS/sources https://www.linuxfromscratch.org/lfs/view/stable/wget-list-sysv
            wget --input-file=wget-list-sysv --continue --directory-prefix=$LFS/sources
            wget -P $LFS/sources https://www.linuxfromscratch.org/lfs/view/stable/md5sums
        elif [[ $tpack == "2" ]]; then
            echo "Verifying Packages"
            sleep 2
            pushd $LFS/sources
                md5sum -c md5sums
            popd
            echo "NOTE: If there are errors you will need to go through"
            echo "the list and manually download the packages."
            echo "Once Completed run the validation once again."
        elif [[ $tpack == "3" ]]; then
            exit
        else
            2>/dev/null
            echo 'Incorrect command. Try again.'
        fi

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
