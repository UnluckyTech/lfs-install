#!/bin/bash

# Search for files whose name matches "coreutils*"
# and save such into the pkg variable.
cd $LFS/sources
pkg=$(find . -maxdepth 1 -type f -name "coreutils*" | head -n 1)

if [ -z "$pkg" ]; then
    echo "Error: No directories matching 'coreutils*' found"
else
    tar -xvf $pkg
    dir=$(find . -maxdepth 1 -type d -name "coreutils*" | head -n 1)
    cd $dir
    ./configure --prefix=/usr --host=$LFS_TGT
    make
    make DESTDIR=$LFS install
fi

# Search for directories whose name matches "coreutils*"
# and save such into the dir variable
cd $LFS/sources
dir=$(find . -maxdepth 1 -type d -name "coreutils*" | head -n 1)

if [ -z "$dir" ]; then
    echo "Error: No directories matching 'coreutils*' found"
else
    rm -rf $dir
fi