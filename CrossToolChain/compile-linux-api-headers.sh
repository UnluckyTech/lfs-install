#!/bin/bash

# Search for files whose name matches "linux*"
# and save such into the dir variable.
cd $LFS/sources
pkg=$(find . -maxdepth 1 -type f -name "linux*" | head -n 1)

if [ -z "$pkg" ]; then
    echo "Error: No directories matching 'linux*' found"
else
    tar -xvf $pkg
    dir=$(find . -maxdepth 1 -type d -name "linux*" | head -n 1)
    cd $dir
    make mrproper
    make headers
    find usr/include -type f ! -name '*.h' -delete
    cp -rv usr/include $LFS/usr
    if [ $? -eq 0 ]; then
        echo "Package compiled successfully"
    else
        echo "Error: Package compilation failed"
        sleep 5
    fi

fi

# Search for directories whose name matches "linux*"
# and save such into the dir variable
cd $LFS/sources
dir=$(find . -maxdepth 1 -type d -name "linux*" | head -n 1)

if [ -z "$dir" ]; then
    echo "Error: No directories matching 'linux*' found"
else
    rm -rf $dir
fi