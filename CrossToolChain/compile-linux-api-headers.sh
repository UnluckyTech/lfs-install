#!/bin/bash

# Search for files whose name matches "linux*"
# and save such into the dir variable.
dir=$(find . -maxdepth 1 -type f -name "linux*" | head -n 1)

if [ -z "$dir" ]; then
    echo "Error: No directories matching 'linux*' found"
else
    cd $LFS/sources
    tar -xvf ${dir}.tar.xz
    cd $dir
    make mrproper
    make headers
    find usr/include -type f ! -name '*.h' -delete
    cp -rv usr/include $LFS/usr

fi

# Search for directories whose name matches "linux*"
# and save such into the dir variable
dir=$(find . -maxdepth 1 -type d -name "linux*" | head -n 1)

if [ -z "$dir" ]; then
    echo "Error: No directories matching 'linux*' found"
else
    cd $LFS/sources
    rm -rf $dir
fi