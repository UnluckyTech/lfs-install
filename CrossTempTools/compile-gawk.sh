#!/bin/bash

# Search for files whose name matches "gawk*"
# and save such into the pkg variable.
cd $LFS/sources
pkg=$(find . -maxdepth 1 -type f -name "gawk*" | head -n 1)

if [ -z "$pkg" ]; then
    echo "Error: No directories matching 'gawk*' found"
else
    tar -xvf $pkg
    dir=$(find . -maxdepth 1 -type d -name "gawk*" | head -n 1)
    cd $dir
    sed -i 's/extras//' Makefile.in
    ./configure --prefix=/usr   \
                --host=$LFS_TGT \
                --build=$(build-aux/config.guess)
    make
    make DESTDIR=$LFS install
fi

# Search for directories whose name matches "gawk*"
# and save such into the dir variable
cd $LFS/sources
dir=$(find . -maxdepth 1 -type d -name "gawk*" | head -n 1)

if [ -z "$dir" ]; then
    echo "Error: No directories matching 'gawk*' found"
else
    rm -rf $dir
fi