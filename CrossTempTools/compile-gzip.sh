#!/bin/bash

# Search for files whose name matches "gzip*"
# and save such into the pkg variable.
cd $LFS/sources
pkg=$(find . -maxdepth 1 -type f -name "gzip*" | head -n 1)

if [ -z "$pkg" ]; then
    echo "Error: No directories matching 'gzip*' found"
else
    tar -xvf $pkg
    dir=$(find . -maxdepth 1 -type d -name "gzip*" | head -n 1)
    cd $dir
    ./configure --prefix=/usr --host=$LFS_TGT
    make
    make DESTDIR=$LFS install
fi

# Search for directories whose name matches "gzip*"
# and save such into the dir variable
cd $LFS/sources
dir=$(find . -maxdepth 1 -type d -name "gzip*" | head -n 1)

if [ -z "$dir" ]; then
    echo "Error: No directories matching 'gzip*' found"
else
    rm -rf $dir
fi
