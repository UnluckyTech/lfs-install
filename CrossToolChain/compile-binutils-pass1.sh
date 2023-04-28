#!/bin/bash

# Search for files whose name matches "binutils*"
# and save such into the dir variable.
dir=$(find . -maxdepth 1 -type f -name "binutils*" | head -n 1)

if [ -z "$dir" ]; then
    echo "Error: No directories matching 'folder*' found"
else
    cd $LFS/sources
    tar -xvf ${dir}.tar.xz
    cd $dir
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

fi

# Search for directories whose name matches "binutils*"
# and save such into the dir variable
dir=$(find . -maxdepth 1 -type d -name "binutils*" | head -n 1)

if [ -z "$dir" ]; then
    echo "Error: No directories matching 'folder*' found"
else
    cd $LFS/sources
    rm -rf $dir
fi