#!/bin/bash

# Search for files whose name matches "binutils*"
# and save such into the dir variable.
cd $LFS/sources
pkg=$(find . -maxdepth 1 -type f -name "binutils*" | head -n 1)

if [ -z "$pkg" ]; then
    echo "Error: No directories matching 'binutils*' found"
else
    tar -xvf $pkg
    dir=$(find . -maxdepth 1 -type d -name "binutils*" | head -n 1)
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
    if [ $? -eq 0 ]; then
        echo "Package compiled successfully"
    else
        echo "Error: Package compilation failed"
        sleep 5
    fi

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