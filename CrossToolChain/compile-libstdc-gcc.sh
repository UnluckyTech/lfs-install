#!/bin/bash

# Search for files whose name matches "linux*"
# and save such into the dir variable.
cd $LFS/sources
pkg=$(find . -maxdepth 1 -type f -name "gcc*" | head -n 1)

if [ -z "$pkg" ]; then
    echo "Error: No directories matching 'gcc*' found"
else
    tar -xvf $pkg
    dir=$(find . -maxdepth 1 -type d -name "gcc*" | head -n 1)
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
cd $LFS/sources
dir=$(find . -maxdepth 1 -type d -name "gcc*" | head -n 1)

if [ -z "$dir" ]; then
    echo "Error: No directories matching 'gcc*' found"
else
    rm -rf $dir
fi