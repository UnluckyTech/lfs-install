#!/bin/bash

# Search for files whose name matches "gcc*"
# and save such into the dir variable.
cd $LFS/sources
pkg=$(find . -maxdepth 1 -type f -name "gcc*" | head -n 1)

if [ -z "$pkg" ]; then
    echo "Error: No directories matching 'gcc*' found"
else
    tar -xvf $pkg
    dir=$(find . -maxdepth 1 -type d -name "gcc*" | head -n 1)
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
            sed -e '/m64=/s/lib64/lib/' \
                -i.orig gcc/config/i386/t-linux64
    ;;
    esac
    mkdir -v build
    cd build
    ../configure                  \
        --target=$LFS_TGT         \
        --prefix=$LFS/tools       \
        --with-glibc-version=2.37 \
        --with-sysroot=$LFS       \
        --with-newlib             \
        --without-headers         \
        --enable-default-pie      \
        --enable-default-ssp      \
        --disable-nls             \
        --disable-shared          \
        --disable-multilib        \
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
fi

# Search for directories whose name matches "gcc*"
# and save such into the dir variable
cd $LFS/sources
dir=$(find . -maxdepth 1 -type d -name "gcc*" | head -n 1)

if [ -z "$dir" ]; then
    echo "Error: No directories matching 'gcc*' found"
else
    rm -rf $dir
fi