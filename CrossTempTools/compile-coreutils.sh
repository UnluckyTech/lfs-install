#!/bin/bash

# Search for files whose name matches "coreutils*"
# and save such into the pkg variable.
cd $LFS/sources
pkg=$(find . -maxdepth 1 -type f -name "coreutils*" | head -n 1)

if [ -z "$pkg" ]; then
    echo "Error: No directories matching 'coreutils*' found"
else
    tar -xvf $pkg
    dir=$(find . -maxdepth 1 -type d -name "coreutils*" | head -n 1)
    cd $dir
    ./configure --prefix=/usr                     \
                --host=$LFS_TGT                   \
                --build=$(build-aux/config.guess) \
                --enable-install-program=hostname \
                --enable-no-install-program=kill,uptime
    make
    make DESTDIR=$LFS install
    mv -v $LFS/usr/bin/chroot              $LFS/usr/sbin
    mkdir -pv $LFS/usr/share/man/man8
    mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
    sed -i 's/"1"/"8"/'                    $LFS/usr/share/man/man8/chroot.8
fi

# Search for directories whose name matches "coreutils*"
# and save such into the dir variable
cd $LFS/sources
dir=$(find . -maxdepth 1 -type d -name "coreutils*" | head -n 1)

if [ -z "$dir" ]; then
    echo "Error: No directories matching 'coreutils*' found"
else
    rm -rf $dir
fi