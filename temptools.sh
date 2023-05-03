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
                elif [[ $finalprep == "3" ]]; then
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
                    echo "Installing Binutils (1/5)"
                    sleep 1
                    . /home/$user/lfs-install/CrossToolChain/compile-binutils-pass1.sh
                    echo "Installing GCC (2/5)"
                    sleep 1
                    . /home/$user/lfs-install/CrossToolChain/compile-gcc-pass1.sh
                    echo "Installing Linux API Headers (3/5)"
                    sleep 1
                    . /home/$user/lfs-install/CrossToolChain/compile-linux-api-headers.sh
                    echo "Installing Glibc (4/5)"
                    sleep 1
                    . /home/$user/lfs-install/CrossToolChain/compile-glibc.sh
                    echo "Installing GCC (5/5)"
                    sleep 1
                    . /home/$user/lfs-install/CrossToolChain/compile-libstdc-gcc.sh
                    echo "Installation Completed"
                    sleep 1
                    
                elif [[ $temp == "2" ]]; then
                    echo "Installing M4 (1/17)"
                    sleep 1
                    . /home/$user/lfs-install/CrossToolChain/compile-m4.sh
                    echo "Installing Ncurses (2/17)"
                    sleep 1
                    . /home/$user/lfs-install/CrossToolChain/compile-ncurses.sh
                    echo " Installing Bash (3/17)"
                    sleep 1
                    . /home/$user/lfs-install/CrossToolChain/compile-bash.sh
                    echo "Installing Coreutils (4/17)"
                    sleep 1
                    . /home/$user/lfs-install/CrossToolChain/compile-coreutils.sh
                    echo "Installing Diffutils (5/17)"
                    sleep 1
                    . /home/$user/lfs-install/CrossToolChain/compile-coreutils.sh
                    echo "Installing File (6/17)"
                    sleep 1
                    . /home/$user/lfs-install/CrossToolChain/compile-file.sh
                    echo "Installing Findutils (7/17)"
                    sleep 1
                    . /home/$user/lfs-install/CrossToolChain/compile-findutils.sh
                    echo "Installing Gawk (8/17)"
                    sleep 1
                    . /home/$user/lfs-install/CrossToolChain/compile-gawk.sh
                    echo "Installing Grep (9/17)"
                    sleep 1
                    . /home/$user/lfs-install/CrossToolChain/compile-grep.sh
                    echo "Installing Gzip (10/17)"
                    sleep 1
                    . /home/$user/lfs-install/CrossToolChain/compile-gzip.sh
                    echo "Installing Make (11/17)"
                    sleep 1
                    tar -xvf make-4.3.tar.gz
                    cd make-4.3
                    ./configure --prefix=/usr   \
                                --without-guile \
                                --host=$LFS_TGT \
                                --build=$(build-aux/config.guess)
                    make
                    make DESTDIR=$LFS install
                    cd $LFS/sources
                    rm -rf make-4.3
                    echo "Installing Patch (12/17)"
                    sleep 1
                    tar -xvf patch-2.7.6.tar.xz
                    cd patch-2.7.6
                    ./configure --prefix=/usr   \
                                --host=$LFS_TGT \
                                --build=$(build-aux/config.guess)
                    make
                    make DESTDIR=$LFS install
                    cd $LFS/sources
                    rm -rf patch-2.7.6
                    echo "Installing Sed (13/17)"
                    sleep 1
                    tar -xvf sed-4.8.tar.xz
                    cd sed-4.8
                    ./configure --prefix=/usr   \
                                --host=$LFS_TGT
                    make
                    make DESTDIR=$LFS install
                    cd $LFS/sources
                    rm -rf sed-4.8
                    echo "Installing Tar (14/17)"
                    sleep 1
                    tar -xvf tar-1.34.tar.xz
                    cd tar-1.34
                    ./configure --prefix=/usr                     \
                                --host=$LFS_TGT                   \
                                --build=$(build-aux/config.guess)
                    make
                    make DESTDIR=$LFS install
                    cd $LFS/sources
                    rm -rf tar-1.34
                    echo "Installing Xz (15/17)"
                    sleep 1
                    tar -xvf xz-5.2.6.tar.xz
                    cd xz-5.2.6
                    ./configure --prefix=/usr                     \
                                --host=$LFS_TGT                   \
                                --build=$(build-aux/config.guess) \
                                --disable-static                  \
                                --docdir=/usr/share/doc/xz-5.2.6
                    make
                    make DESTDIR=$LFS install
                    rm -v $LFS/usr/lib/liblzma.la
                    cd $LFS/sources
                    rm -rf xz-5.2.6
                    echo "Installing Binutils pt2 (16/17)"
                    sleep 1
                    tar -xvf binutils-2.39.tar.xz
                    cd binutils-2.39
                    sed '6009s/$add_dir//' -i ltmain.sh
                    mkdir -v build
                    cd build
                    ../configure                   \
                        --prefix=/usr              \
                        --build=$(../config.guess) \
                        --host=$LFS_TGT            \
                        --disable-nls              \
                        --enable-shared            \
                        --enable-gprofng=no        \
                        --disable-werror           \
                        --enable-64-bit-bfd
                    make
                    make DESTDIR=$LFS install
                    rm -v $LFS/usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.{a,la}
                    cd $LFS/sources
                    rm -rf binutils-2.39
                    echo "Installing GCC pt2 (17/17)"
                    sleep 1
                    tar -xvf gcc-12.2.0.tar.xz
                    cd gcc-12.2.0
                    tar -xf ../mpfr-4.1.0.tar.xz
                    mv -v mpfr-4.1.0 mpfr
                    tar -xf ../gmp-6.2.1.tar.xz
                    mv -v gmp-6.2.1 gmp
                    tar -xf ../mpc-1.2.1.tar.gz
                    mv -v mpc-1.2.1 mpc
                    case $(uname -m) in
                        x86_64)
                            sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
                        ;;
                    esac
                    sed '/thread_header =/s/@.*@/gthr-posix.h/' \
                    -i libgcc/Makefile.in libstdc++-v3/include/Makefile.in
                    mkdir -v build
                    cd build
                    ../configure                                       \
                        --build=$(../config.guess)                     \
                        --host=$LFS_TGT                                \
                        --target=$LFS_TGT                              \
                        LDFLAGS_FOR_TARGET=-L$PWD/$LFS_TGT/libgcc      \
                        --prefix=/usr                                  \
                        --with-build-sysroot=$LFS                      \
                        --enable-initfini-array                        \
                        --disable-nls                                  \
                        --disable-multilib                             \
                        --disable-decimal-float                        \
                        --disable-libatomic                            \
                        --disable-libgomp                              \
                        --disable-libquadmath                          \
                        --disable-libssp                               \
                        --disable-libvtv                               \
                        --enable-languages=c,c++
                    make
                    make DESTDIR=$LFS install
                    ln -sv gcc $LFS/usr/bin/cc
                    cd $LFS/sources
                    rm -rf gcc-12.2.0
                    echo "Installation Completed"
                elif [[ $temp == "3" ]]; then
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
                        mkdir -pv /{boot,home,mnt,opt,srv}
                        mkdir -pv /etc/{opt,sysconfig}
                        mkdir -pv /lib/firmware
                        mkdir -pv /media/{floppy,cdrom}
                        mkdir -pv /usr/{,local/}{include,src}
                        mkdir -pv /usr/local/{bin,lib,sbin}
                        mkdir -pv /usr/{,local/}share/{color,dict,doc,info,locale,man}
                        mkdir -pv /usr/{,local/}share/{misc,terminfo,zoneinfo}
                        mkdir -pv /usr/{,local/}share/man/man{1..8}
                        mkdir -pv /var/{cache,local,log,mail,opt,spool}
                        mkdir -pv /var/lib/{color,misc,locate}

                        ln -sfv /run /var/run
                        ln -sfv /run/lock /var/lock

                        install -dv -m 0750 /root
                        install -dv -m 1777 /tmp /var/tmp
                        echo "Creating Essential Files and Symlinks"
                        ln -sv /proc/self/mounts /etc/mtab
                        cat > /etc/hosts << EOF
                        127.0.0.1  localhost $(hostname)
                        ::1        localhost
EOF
                        cat > /etc/passwd << "EOF"
                        root:x:0:0:root:/root:/bin/bash
                        bin:x:1:1:bin:/dev/null:/usr/bin/false
                        daemon:x:6:6:Daemon User:/dev/null:/usr/bin/false
                        messagebus:x:18:18:D-Bus Message Daemon User:/run/dbus:/usr/bin/false
                        uuidd:x:80:80:UUID Generation Daemon User:/dev/null:/usr/bin/false
                        nobody:x:65534:65534:Unprivileged User:/dev/null:/usr/bin/false
EOF
                        cat > /etc/group << "EOF"
                        root:x:0:
                        bin:x:1:daemon
                        sys:x:2:
                        kmem:x:3:
                        tape:x:4:
                        tty:x:5:
                        daemon:x:6:
                        floppy:x:7:
                        disk:x:8:
                        lp:x:9:
                        dialout:x:10:
                        audio:x:11:
                        video:x:12:
                        utmp:x:13:
                        usb:x:14:
                        cdrom:x:15:
                        adm:x:16:
                        messagebus:x:18:
                        input:x:24:
                        mail:x:34:
                        kvm:x:61:
                        uuidd:x:80:
                        wheel:x:97:
                        users:x:999:
                        nogroup:x:65534:
EOF
                        echo "tester:x:101:101::/home/tester:/bin/bash" >> /etc/passwd
                        echo "tester:x:101:" >> /etc/group
                        install -o tester -d /home/tester
                        exec /usr/bin/bash --login
                        touch /var/log/{btmp,lastlog,faillog,wtmp}
                        chgrp -v utmp /var/log/lastlog
                        chmod -v 664  /var/log/lastlog
                        chmod -v 600  /var/log/btmp
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
                        exit
                    fi


                elif [[ $temp == "4" ]]; then
                    echo "nuh"
                elif [[ $temp == "5" ]]; then
                    exit
                fi
            done
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
        echo "Would you like to mount it now? (y/N)"
        read choice
        if [[ $choice == "y" ]]; then
            LFS=/mnt/lfs
        else
            exit
        fi
    fi
        
done
