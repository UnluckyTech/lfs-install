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
                    echo "Installing M4 (1/17)"
                    sleep 1
                    cd $LFS/sources
                    tar -xvf m4-1.4.19.tar.xz
                    cd m4-1.4.19
                    ./configure --prefix=/usr   \
                                --host=$LFS_TGT \
                                --build=$(build-aux/config.guess)
                    make
                    make DESTDIR=$LFS install
                    cd $LFS/sources
                    rm -rf m4-1.4.19
                    echo "Installing Ncurses (2/17)"
                    sleep 1
                    tar -xvf ncurses-6.3.tar.gz
                    cd ncurses-6.3
                    sed -i s/mawk// configure
                    mkdir build
                    pushd build
                        ../configure
                        make -C include
                        make -C progs tic
                    popd
                    ./configure --prefix=/usr                \
                                --host=$LFS_TGT              \
                                --build=$(./config.guess)    \
                                --mandir=/usr/share/man      \
                                --with-manpage-format=normal \
                                --with-shared                \
                                --without-normal             \
                                --with-cxx-shared            \
                                --without-debug              \
                                --without-ada                \
                                --disable-stripping          \
                                --enable-widec
                    make
                    make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
                    echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so
                    cd $LFS/sources
                    rm -rf ncurses-6.3
                    echo " Installing Bash (3/17)"
                    sleep 1
                    tar -xvf bash-5.1.16.tar.gz
                    cd bash-5.1.16
                    ./configure --prefix=/usr                   \
                                --build=$(support/config.guess) \
                                --host=$LFS_TGT                 \
                                --without-bash-malloc
                    make
                    make DESTDIR=$LFS install
                    ln -sv bash $LFS/bin/sh
                    cd $LFS/sources
                    rm -rf bash-5.1.16
                    echo "Installing Coreutils (4/17)"
                    sleep 1
                    tar -xvf coreutils-9.1.tar.xz
                    cd coreutils-9.1
                    ./configure --prefix=/usr                     \
                                --host=$LFS_TGT                   \
                                --build=$(build-aux/config.guess) \
                                --enable-install-program=hostname \
                                --enable-no-install-program=kill,uptime
                    make
                    make DESTDIR=$LFS install
                    mv -v $LFS/usr/bin/chroot              $LFS/usr/sbin
                    mkdir -pv $LFS/usr/share/man/man8
                    mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
                    sed -i 's/"1"/"8"/'                    $LFS/usr/share/man/man8/chroot.8
                    cd $LFS/sources
                    rm -rf coreutils-9.1.tar.xz
                    echo "Installing Diffutils (5/17)"
                    sleep 1
                    tar -xvf diffutils-3.8.tar.xz
                    cd diffutils-3.8
                    ./configure --prefix=/usr --host=$LFS_TGT
                    make
                    make DESTDIR=$LFS install
                    cd $LFS/sources
                    rm -rf diffutils-3.8
                    echo "Installing File (6/17)"
                    sleep 1
                    tar -xvf file-5.42.tar.gz
                    cd file-5.42
                    mkdir build
                    pushd build
                        ../configure --disable-bzlib      \
                                     --disable-libseccomp \
                                     --disable-xzlib      \
                                     --disable-zlib
                        make
                    popd
                    ./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
                    make FILE_COMPILE=$(pwd)/build/src/file
                    make DESTDIR=$LFS install
                    rm -v $LFS/usr/lib/libmagic.la
                    cd $LFS/sources
                    rm -rf file-5.42
                    echo "Installing Findutils (7/17)"
                    sleep 1
                    tar -xvf findutils-4.9.0.tar.xz
                    cd findutils-4.9.0
                    ./configure --prefix=/usr                   \
                                --localstatedir=/var/lib/locate \
                                --host=$LFS_TGT                 \
                                --build=$(build-aux/config.guess)
                    make
                    make DESTDIR=$LFS install
                    cd $LFS/sources
                    rm -rf findutils-4.9.0
                    echo "Installing Gawk (8/17)"
                    sleep 1
                    tar -xvf gawk-5.1.1.tar.xz
                    cd gawk-5.1.1
                    sed -i 's/extras//' Makefile.in
                    ./configure --prefix=/usr   \
                                --host=$LFS_TGT \
                                --build=$(build-aux/config.guess)
                    make
                    make DESTDIR=$LFS install
                    cd $LFS/sources
                    rm -rf gawk-5.1.1
                    echo "Installing Grep (9/17)"
                    sleep 1
                    tar -xvf grep-3.7.tar.xz
                    cd grep-3.7
                    ./configure --prefix=/usr   \
                                --host=$LFS_TGT
                    make
                    make DESTDIR=$LFS install
                    cd $LFS/sources
                    rm -rf grep-3.7
                    echo "Installing Gzip (10/17)"
                    sleep 1
                    tar -xvf gzip-1.12.tar.xz
                    cd gzip-1.12
                    ./configure --prefix=/usr --host=$LFS_TGT
                    make
                    make DESTDIR=$LFS install
                    cd $LFS/sources
                    rm -rf gzip-1.12
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
