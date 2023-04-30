#!/bin/bash

# Search for files whose name matches "glibc*"
# and save such into the dir variable.
dir=$(find . -maxdepth 1 -type f -name "glibc*" | head -n 1)

if [ -z "$dir" ]; then
    echo "Error: No directories matching 'glibc*' found"
else
    cd $LFS/sources
    tar -xvf ${dir}.tar.xz
    cd $dir
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

fi

# Search for directories whose name matches "glibc*"
# and save such into the dir variable
dir=$(find . -maxdepth 1 -type d -name "glibc*" | head -n 1)

if [ -z "$dir" ]; then
    echo "Error: No directories matching 'glibc*' found"
else
    cd $LFS/sources
    rm -rf $dir
fi