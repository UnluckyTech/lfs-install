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
        user="$(whoami)"
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
                    . /home/$user/lfs-install/temptools.sh
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
                user="$(whoami)"
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
                    echo "Enter lfs password"
                    read lfspass
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
                    echo "How many cores we are using?"
                    read core
                    echo "export MAKEFLAGS='-j$core'" >> ~/.bashrc
                    source ~/.bash_profile
                elif [[ $finalprep == "3" ]]; then
                    . /home/$user/lfs-install/temptools.sh
                    exit
                fi
            done
        elif [[ $option == "3" ]]; then 
            while true
            do
                echo ''
                echo '*********************************'
                echo '***** Build Cross/Temp Tools ****'
                echo '*********************************'
                echo '1. Compile Cross-Toolchain'
                echo '2. Cross Compile Temp Tools'
                echo '3. Enter Chroot'
                echo '4. Build Additional Temp Tools'
                echo '5. Return to TempTools'
                user="$(whoami)"
                read temp
                if [[ $temp == "1" ]]; then
                    . /home/$user/lfs-install/CrossToolChain/tcindex.sh
                    
                elif [[ $temp == "2" ]]; then
                    . /home/$user/lfs-install/CrossTempTools/ttindex.sh
                    echo "Installation Completed"
                elif [[ $temp == "3" ]]; then
                    if [ $(whoami) == "root" ]; then
                        echo "You are root. Proceeding with installation."
                        echo ''
                        echo '*********************************'
                        echo '********** Enter Chroot *********'
                        echo '*********************************'
                        echo '1. Changing Ownership'
                        echo '2. Enter Chroot'
                        echo '3. Create Directories'
                        echo '4. Build Additional Temp Tools'
                        echo '5. Clean and Backup Temp System'
                        echo '6. Return to TempTools'
                        user="$(whoami)"
                        read inpchr
                        if [[ $inpchr == "1" ]]; then
                            echo "Changing Ownership"
                            chown -R root:root $LFS/{usr,lib,var,etc,bin,sbin,tools}
                            case $(uname -m) in
                            x86_64) chown -R root:root $LFS/lib64 ;;
                            esac
                            echo "Preparing Virtual Kernel File Systems"
                            mkdir -pv $LFS/{dev,proc,sys,run}
                            mount -v --bind /dev $LFS/dev
                            mount -v --bind /dev/pts $LFS/dev/pts
                            mount -vt proc proc $LFS/proc
                            mount -vt sysfs sysfs $LFS/sys
                            mount -vt tmpfs tmpfs $LFS/run
                            if [ -h $LFS/dev/shm ]; then
                                mkdir -pv $LFS/$(readlink $LFS/dev/shm)
                            else
                                mount -t tmpfs -o nosuid,nodev tmpfs $LFS/dev/shm
                            fi
                        elif [[ $inpchr == "2" ]]; then
                            chroot "$LFS" /usr/bin/env -i   \
                                HOME=/root                  \
                                TERM="$TERM"                \
                                PS1='(lfs chroot) \u:\w\$ ' \
                                PATH=/usr/bin:/usr/sbin     \
                                /bin/bash --login
                        elif [[ $inpchr == "3" ]]; then
                            echo "Creating Directories"
                        elif [[ $inpchr == "4" ]]; then
                            cd $LFS/sources
                            echo "Installing Gettext (1/6)"
                            sleep 1
                            tar -xvf gettext-0.21.tar.xz
                            cd gettext-0.21
                            ./configure --disable-shared
                            make
                            cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin
                            cd $LFS/sources
                            rm -rf gettext-0.21
                            echo "Installing Bison (2/6)"
                            sleep 1
                            tar -xvf bison-3.8.2.tar.xz
                            cd bison-3.8.2
                            ./configure --prefix=/usr \
                                        --docdir=/usr/share/doc/bison-3.8.2
                            make
                            make install
                            cd $LFS/sources
                            rm -rf bison-3.8.2
                            echo "Installing Perl (3/6)"
                            sleep 1
                            tar -xvf perl-5.36.0.tar.xz
                            cd perl-5.36.0
                            sh Configure -des                                        \
                                        -Dprefix=/usr                               \
                                        -Dvendorprefix=/usr                         \
                                        -Dprivlib=/usr/lib/perl5/5.36/core_perl     \
                                        -Darchlib=/usr/lib/perl5/5.36/core_perl     \
                                        -Dsitelib=/usr/lib/perl5/5.36/site_perl     \
                                        -Dsitearch=/usr/lib/perl5/5.36/site_perl    \
                                        -Dvendorlib=/usr/lib/perl5/5.36/vendor_perl \
                                        -Dvendorarch=/usr/lib/perl5/5.36/vendor_perl
                            make
                            make install
                            cd $LFS/sources
                            rm -rf perl-5.36.0
                            echo "Installing Python (4/6)"
                            sleep 1
                            tar -xvf Python-3.10.6.tar.xz
                            cd Python-3.10.6
                            ./configure --prefix=/usr   \
                                        --enable-shared \
                                        --without-ensurepip
                            make
                            make install
                            cd $LFS/sources
                            rm -rf Python-3.10.6
                            echo "Installing Texinfo (5/6)"
                            sleep 1
                            tar -xvf texinfo-6.8.tar.xz
                            cd texinfo-6.8
                            ./configure --prefix=/usr
                            make
                            make install
                            cd $LFS/sources
                            rm -rf texinfo-6.8
                            echo "Installing Util Linux (6/6)"
                            sleep 1
                            tar -xvf util-linux-2.38.1.tar.xz
                            cd util-linux-2.38.1
                            ./configure ADJTIME_PATH=/var/lib/hwclock/adjtime    \
                                        --libdir=/usr/lib    \
                                        --docdir=/usr/share/doc/util-linux-2.38.1 \
                                        --disable-chfn-chsh  \
                                        --disable-login      \
                                        --disable-nologin    \
                                        --disable-su         \
                                        --disable-setpriv    \
                                        --disable-runuser    \
                                        --disable-pylibmount \
                                        --disable-static     \
                                        --without-python     \
                                        runstatedir=/run
                            make
                            make install
                            cd $LFS/sources
                            rm -rf util-linux-2.38.1
                            echo "Installation Completed"
                            echo "Cleaning Up..."
                            rm -rf /usr/share/{info,man,doc}/*
                            find /usr/{lib,libexec} -name \*.la -delete
                            rm -rf /tools
                        
                        elif [[ $inpchr == "5" ]]; then
                            echo "Backing Up..."
                            umount $LFS/dev/pts
                            umount $LFS/{sys,proc,run,dev}
                            cd $LFS
                            tar -cJpf $HOME/lfs-temp-tools-11.2.tar.xz .
                            echo "Back Up Completed."
                        elif [[ $inpchr == "6" ]]; then
                            . /home/$user/lfs-install/temptools.sh
                            exit
                        else
                            2>/dev/null
                            echo 'Incorrect command. Try again.'
                        fi
                    else
                        echo "You need to be root to run this script."
                        exit 1
                    fi

                elif [[ $temp == "4" ]]; then
                    echo "nuh"
                elif [[ $temp == "5" ]]; then
                    . /home/$user/lfs-install/temptools.sh
                    exit
                fi
            done
        elif [[ $option == "4" ]]; then
            echo 'nuh'
        elif [[ $option == "5" ]]; then
            . /home/$user/lfs-install/main.sh
        else
            2>/dev/null
            echo 'Incorrect command. Try again.'
        fi
    else
        echo "LFS variable is not mounted."
        echo "Would you like to mount it now? (y/N)"
        read choice
        if [[ $choice == "y" ]]; then
            LFS=/mnt/lfs
        else
            exit
        fi
    fi
        
done
