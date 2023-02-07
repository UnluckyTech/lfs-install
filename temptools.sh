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

                read temp
                if [[ $temp == "1" ]]; then
                    echo "Installing Binutils (1/5)"
                    sleep 1
                    cd $LFS/sources
                    tar -xvf binutils-2.39.tar.xz
                    cd binutils-2.39
                    mkdir -v build
                    cd build
                    ../configure --prefix=$LFS/tools \
                                 --with-sysroot=$LFS \
                                 --target=$LFS_TGT   \
                                 --disable-nls       \
                                 --enable-gprofng=no \
                                 --disable-werror
                    make
                    make install
                    cd $LFS/sources
                    rm -rf binutils2.39
                    echo "Installing GCC (2/5)"
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
                            sed -e '/m64=/s/lib64/lib/' \
                                -i.orig gcc/config/i386/t-linux64
                    ;;
                    esac
                    mkdir -v build
                    cd build
                    ../configure                  \
                        --target=$LFS_TGT         \
                        --prefix=$LFS/tools       \
                        --with-glibc-version=2.36 \
                        --with-sysroot=$LFS       \
                        --with-newlib             \
                        --without-headers         \
                        --disable-nls             \
                        --disable-shared          \
                        --disable-multilib        \
                        --disable-decimal-float   \
                        --disable-threads         \
                        --disable-libatomic       \
                        --disable-libgomp         \
                        --disable-libquadmath     \
                        --disable-libssp          \
                        --disable-libvtv          \
                        --disable-libstdcxx       \
                        --enable-languages=c,c++
                    make
                    make install
                    cd ..
                    cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
                      `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
                    cd $LFS/sources
                    rm -rf gcc-12.2.0
                    echo "Installing Linux API Headers (3/5)"
                    sleep 1
                    tar -xvf linux-5.19.2.tar.xz
                    cd linux-5.19.2
                    make mrproper
                    make headers
                    find usr/include -type f ! -name '*.h' -delete
                    cp -rv usr/include $LFS/usr
                    cd $LFS/sources
                    rm -rf linux-5.19.2
                    echo "Installing Glibc (4/5)"
                    sleep 1
                    tar -xvf glibc-2.36.tar.xz
                    cd glibc-2.36
                    case $(uname -m) in
                        i?86)   ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
                        ;;
                        x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
                                ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
                        ;;
                    esac
                    patch -Np1 -i ../glibc-2.36-fhs-1.patch
                    mkdir -v build
                    cd build
                    echo "rootsbindir=/usr/sbin" > configparms
                    ../configure                             \
                        --prefix=/usr                      \
                        --host=$LFS_TGT                    \
                        --build=$(../scripts/config.guess) \
                        --enable-kernel=3.2                \
                        --with-headers=$LFS/usr/include    \
                        libc_cv_slibdir=/usr/lib
                    make
                    make DESTDIR=$LFS install
                    sed '/RTLDLIST=/s@/usr@@g' -i $LFS/usr/bin/ldd
                    echo 'int main(){}' | gcc -xc -
                    readelf -l a.out | grep ld-linux
                    echo "There should NOT be any ERRORS"
                    sleep 10
                    rm -v a.out
                    $LFS/tools/libexec/gcc/$LFS_TGT/12.2.0/install-tools/mkheaders
                    cd $LFS/sources
                    rm glibc-2.36
                    echo "Installing GCC (5/5)"
                    sleep 1
                    tar -xvf gcc-12.2.0.tar.xz
                    cd gcc-12.2.0
                    mkdir -v build
                    cd build
                    ../libstdc++-v3/configure           \
                        --host=$LFS_TGT                 \
                        --build=$(../config.guess)      \
                        --prefix=/usr                   \
                        --disable-multilib              \
                        --disable-nls                   \
                        --disable-libstdcxx-pch         \
                        --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/12.2.0
                    make
                    make DESTDIR=$LFS install
                    rm -v $LFS/usr/lib/lib{stdc++,stdc++fs,supc++}.la
                    cd $LFS/sources
                    rm -rf gcc-12.2.0
                    echo "Installation Completed"
                    sleep 1
                    
                elif [[ $temp == "2" ]]; then
                    echo "nuh"
                elif [[ $temp == "3" ]]; then
                    echo "nuh"
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
