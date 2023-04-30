#!/bin/bash

# Search for files whose name matches "linux*"
# and save such into the dir variable.
dir=$(find . -maxdepth 1 -type f -name "gcc*" | head -n 1)

if [ -z "$dir" ]; then
    echo "Error: No directories matching 'linux*' found"
else
    cd $LFS/sources
    tar -xvf ${dir}.tar.xz
    cd $dir
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


fi

# Search for directories whose name matches "linux*"
# and save such into the dir variable
dir=$(find . -maxdepth 1 -type d -name "linux*" | head -n 1)

if [ -z "$dir" ]; then
    echo "Error: No directories matching 'linux*' found"
else
    cd $LFS/sources
    rm -rf $dir
fi