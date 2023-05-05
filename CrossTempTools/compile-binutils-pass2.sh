#!/bin/bash

# Search for files whose name matches "binutils*"
# and save such into the pkg variable.
cd $LFS/sources
pkg=$(find . -maxdepth 1 -type f -name "binutils*" | head -n 1)

if [ -z "$pkg" ]; then
    echo "Error: No directories matching 'binutils*' found"
else
    tar -xvf $pkg
    dir=$(find . -maxdepth 1 -type d -name "binutils*" | head -n 1)
    cd $dir
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
fi

# Search for directories whose name matches "binutils*"
# and save such into the dir variable
cd $LFS/sources
dir=$(find . -maxdepth 1 -type d -name "binutils*" | head -n 1)

if [ -z "$dir" ]; then
    echo "Error: No directories matching 'binutils*' found"
else
    rm -rf $dir
fi