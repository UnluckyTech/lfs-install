#!/bin/bash

# Search for files whose name matches "file*"
# and save such into the pkg variable.
cd $LFS/sources
pkg=$(find . -maxdepth 1 -type f -name "file*" | head -n 1)

if [ -z "$pkg" ]; then
    echo "Error: No directories matching 'file*' found"
else
    tar -xvf $pkg
    dir=$(find . -maxdepth 1 -type d -name "file*" | head -n 1)
    cd $dir
    mkdir build
    pushd build
        ../configure --disable-bzlib      \
                     --disable-libseccomp \
                     --disable-xzlib      \
                     --disable-zlib
        make
    popd
    ./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess)
    make FILE_COMPILE=$(pwd)/build/src/file
    make DESTDIR=$LFS install
    rm -v $LFS/usr/lib/libmagic.la
fi

# Search for directories whose name matches "file*"
# and save such into the dir variable
cd $LFS/sources
dir=$(find . -maxdepth 1 -type d -name "file*" | head -n 1)

if [ -z "$dir" ]; then
    echo "Error: No directories matching 'file*' found"
else
    rm -rf $dir
fi
