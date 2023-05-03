#!/bin/bash

# Search for files whose name matches "m4*"
# and save such into the dir variable.
cd $LFS/sources
pkg=$(find . -maxdepth 1 -type f -name "m4*" | head -n 1)

if [ -z "$pkg" ]; then
    echo "Error: No directories matching 'm4*' found"
else
    tar -xvf $pkg
    dir=$(find . -maxdepth 1 -type d -name "m4*" | head -n 1)
    cd $dir
    ./configure --prefix=/usr   \
                --host=$LFS_TGT \
                --build=$(build-aux/config.guess)
    make
    make DESTDIR=$LFS install
    if [ $? -eq 0 ]; then
        echo "Package compiled successfully"
    else
        echo "Error: Package compilation failed"
        sleep 5
    fi
fi

# Search for directories whose name matches "m4*"
# and save such into the dir variable
cd $LFS/sources
dir=$(find . -maxdepth 1 -type d -name "m4*" | head -n 1)

if [ -z "$dir" ]; then
    echo "Error: No directories matching 'm4*' found"
else
    rm -rf $dir
fi