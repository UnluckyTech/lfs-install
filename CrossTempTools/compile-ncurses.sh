#!/bin/bash

# Search for files whose name matches "ncurses*"
# and save such into the dir variable.
cd $LFS/sources
pkg=$(find . -maxdepth 1 -type f -name "ncurses*" | head -n 1)

if [ -z "$pkg" ]; then
    echo "Error: No directories matching 'ncurses*' found"
else
    tar -xvf $pkg
    dir=$(find . -maxdepth 1 -type d -name "ncurses*" | head -n 1)
    cd $dir
    sed -i s/mawk// configure
    mkdir build
    pushd build
        ../configure
        make -C include
        make -C progs tic
    popd
    ./configure --prefix=/usr                \
                --host=$LFS_TGT              \
                --build=$(./config.guess)    \
                --mandir=/usr/share/man      \
                --with-manpage-format=normal \
                --with-shared                \
                --without-normal             \
                --with-cxx-shared            \
                --without-debug              \
                --without-ada                \
                --disable-stripping          \
                --enable-widec
    make
    make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install
    echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so
    if [ $? -eq 0 ]; then
        echo "Package compiled successfully"
    else
        echo "Error: Package compilation failed"
        sleep 5
    fi
fi

# Search for directories whose name matches "ncurses*"
# and save such into the dir variable
cd $LFS/sources
dir=$(find . -maxdepth 1 -type d -name "ncurses*" | head -n 1)

if [ -z "$dir" ]; then
    echo "Error: No directories matching 'ncurses*' found"
else
    rm -rf $dir
fi