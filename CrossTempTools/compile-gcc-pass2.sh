#!/bin/bash

# Search for files whose name matches "temp*"
# and save such into the pkg variable.
cd $LFS/sources
pkg=$(find . -maxdepth 1 -type f -name "temp*" | head -n 1)

if [ -z "$pkg" ]; then
    echo "Error: No directories matching 'temp*' found"
else
    tar -xvf $pkg
    dir=$(find . -maxdepth 1 -type d -name "temp*" | head -n 1)
    cd $dir
    mpfr=$(find . -maxdepth 1 -type f -name "mpfr*" | head -n 1)
    gmp=$(find . -maxdepth 1 -type f -name "gmp*" | head -n 1)
    mpc=$(find . -maxdepth 1 -type f -name "mpc*" | head -n 1)
    tar -xf ../${mpfr}
    mpfrd=$(find . -maxdepth 1 -type d -name "mpfr*" | head -n 1)
    mv -v $mpfrd mpfr
    tar -xf ../${gmp}
    gmpd=$(find . -maxdepth 1 -type d -name "gmp*" | head -n 1)
    mv -v $gmpd gmp
    tar -xf ../${mpc}
    mpcd=$(find . -maxdepth 1 -type d -name "mpc*" | head -n 1)
    mv -v $mpcd mpc
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
fi

# Search for directories whose name matches "temp*"
# and save such into the dir variable
cd $LFS/sources
dir=$(find . -maxdepth 1 -type d -name "temp*" | head -n 1)

if [ -z "$dir" ]; then
    echo "Error: No directories matching 'temp*' found"
else
    rm -rf $dir
fi