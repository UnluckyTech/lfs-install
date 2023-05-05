#!/bin/bash

# Search for files whose name matches "xz*"
# and save such into the pkg variable.
cd $LFS/sources
pkg=$(find . -maxdepth 1 -type f -name "xz*" | head -n 1)

if [ -z "$pkg" ]; then
    echo "Error: No directories matching 'xz*' found"
else
    tar -xvf $pkg
    dir=$(find . -maxdepth 1 -type d -name "xz*" | head -n 1)
    cd $dir
    ./configure --prefix=/usr                     \
                --host=$LFS_TGT                   \
                --build=$(build-aux/config.guess) \
                --disable-static                  \
                --docdir=/usr/share/doc/xz-5.2.6
    make
    make DESTDIR=$LFS install
fi

# Search for directories whose name matches "xz*"
# and save such into the dir variable
cd $LFS/sources
dir=$(find . -maxdepth 1 -type d -name "xz*" | head -n 1)

if [ -z "$dir" ]; then
    echo "Error: No directories matching 'xz*' found"
else
    rm -rf $dir
fi