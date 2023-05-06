#!/bin/bash

# Search for files whose name matches "bash*"
# and save such into the dir variable.
cd $LFS/sources
pkg=$(find . -maxdepth 1 -type f -name "bash*" | head -n 1)

if [ -z "$pkg" ]; then
    echo "Error: No directories matching 'bash*' found"
else
    tar -xvf $pkg
    dir=$(find . -maxdepth 1 -type d -name "bash*" | head -n 1)
    cd $dir
    ./configure --prefix=/usr                   \
                --build=$(sh support/config.guess) \
                --host=$LFS_TGT                 \
                --without-bash-malloc
    make
    make DESTDIR=$LFS install
    ln -sv bash $LFS/bin/sh
fi

# Search for directories whose name matches "bash*"
# and save such into the dir variable
cd $LFS/sources
dir=$(find . -maxdepth 1 -type d -name "bash*" | head -n 1)

if [ -z "$dir" ]; then
    echo "Error: No directories matching 'bash*' found"
else
    rm -rf $dir
fi