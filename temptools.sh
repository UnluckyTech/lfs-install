while true
do
    if [[ "$LFS" ]]; then
        echo ''
        echo '*********************************'
        echo '********* LFS  TempTools ********'
        echo '*********************************'
        echo '1. Packages and Patches'
        echo '2. Final Preperations'
        echo '3. Build Cross/Temp Tools'
        echo '4. Cross Compile Tools'
        echo '5. Return to Installer'
        read option
        if [[ $option == "1" ]]; then
            while true
            do
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
                    echo "https://www.linuxfromscratch.org/lfs/view/stable/chapter03/packages.html"
                elif [[ $tpack == "3" ]]; then
                    exit
                else
                    2>/dev/null
                    echo 'Incorrect command. Try again.'
                fi
            done

        elif [[ $option == "2" ]]; then
            while true
            do
                echo ''
                echo '*********************************'
                echo '******* Final Preperations ******'
                echo '*********************************'
                echo '1. Configure LFS User'
                echo '2. Set Up Environment'
                echo '3. Return to TempTools'
                read finalprep
                if [[ $finalprep == "1" ]]; then
                    echo "Creating Required Directories"
                    sleep 1
                    mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}

                    for i in bin lib sbin; do
                    ln -sv usr/$i $LFS/$i
                    done

                    case $(uname -m) in
                    x86_64) mkdir -pv $LFS/lib64 ;;
                    esac
                    mkdir -pv $LFS/tools
                    echo "Adding LFS User"
                    groupadd lfs
                    useradd -s /bin/bash -g lfs -m -k /dev/null lfs
                    read lfspass
                    echo "Enter lfs password"
                    ( echo $lfspass ; echo $lfspass ) | passwd lfs
                    chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}
                    case $(uname -m) in
                    x86_64) chown -v lfs $LFS/lib64 ;;
                    esac
                    echo "You will now log into lfs"
                    su - lfs
                elif [[ $finalprep == "2" ]]; then
                    echo "Setting Up Environment"
                    sleep 2
                    cat > ~/.bash_profile << "EOF"
                    exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF
                    cat > ~/.bashrc << "EOF"
                    set +h
                    umask 022
                    LFS=/mnt/lfs
                    LC_ALL=POSIX
                    LFS_TGT=$(uname -m)-lfs-linux-gnu
                    PATH=/usr/bin
                    if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
                    PATH=$LFS/tools/bin:$PATH
                    CONFIG_SITE=$LFS/usr/share/config.site
                    export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
EOF
                fi
            done
        elif [[ $option == "3" ]]; then 
            echo 'nuh'
        elif [[ $option == "4" ]]; then
            echo 'nuh'
        elif [[ $option == "5" ]]; then
            exit
        else
            2>/dev/null
            echo 'Incorrect command. Try again.'
        fi
    else
        echo "LFS variable is not mounted."
        echo "Return to previous menu to configure."
        exit
    fi
        
done
