#!/bin/bash

# Search for files whose name matches "make*"
# and save such into the pkg variable.
cd $LFS/sources
pkg=$(find . -maxdepth 1 -type f -name "make*" | head -n 1)

if [ -z "$pkg" ]; then
    echo "Error: No directories matching 'make*' found"
else
    tar -xvf $pkg
    dir=$(find . -maxdepth 1 -type d -name "make*" | head -n 1)
    cd $dir
    sed -e '/ifdef SIGPIPE/,+2 d' \
        -e '/undef  FATAL_SIG/i FATAL_SIG (SIGPIPE);' \
        -i src/main.c
    ./configure --prefix=/usr   \
                --without-guile \
                --host=$LFS_TGT \
                --build=$(build-aux/config.guess)
    make
    make DESTDIR=$LFS install
fi

# Search for directories whose name matches "make*"
# and save such into the dir variable
cd $LFS/sources
dir=$(find . -maxdepth 1 -type d -name "make*" | head -n 1)

if [ -z "$dir" ]; then
    echo "Error: No directories matching 'make*' found"
else
    rm -rf $dir
fi