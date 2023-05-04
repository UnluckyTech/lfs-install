#!/bin/bash

# List of packages to compile
packages=("binutils-pass1" "gcc-pass1" "linux-api-headers" "glibc" "libstdc-gcc")

# Initialize compilation status for each package
declare -A status
for package in "${packages[@]}"; do
    status[$package]=0
done

# Compile each package using its compilation script and update compilation status
for package in "${packages[@]}"; do
    echo "Compiling $package"
    case $package in
        "binutils-pass1")
            echo "Installing Binutils (1/5)"
            sleep 1
            . /home/$user/lfs-install/CrossToolChain/compile-binutils-pass1.sh
            ;;
        "gcc-pass1")
            echo "Installing GCC (2/5)"
            sleep 1
            . /home/$user/lfs-install/CrossToolChain/compile-gcc-pass1.sh
            ;;
        "linux-api-headers")
            echo "Installing Linux API Headers (3/5)"
            sleep 1
            . /home/$user/lfs-install/CrossToolChain/compile-linux-api-headers.sh
            ;;
        "glibc")
            echo "Installing Glibc (4/5)"
            sleep 1
            . /home/$user/lfs-install/CrossToolChain/compile-glibc.sh
            ;;
        "libstdc-gcc")
            echo "Installing GCC (5/5)"
            sleep 1
            . /home/$user/lfs-install/CrossToolChain/compile-libstdc-gcc.sh
            ;;
        *)
            echo "Unknown package: $package"
            status[$package]=1
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        status[$package]=0
        echo "$package compiled successfully"
    else
        status[$package]=1
        echo "Error: $package compilation failed"
    fi
done

# Report which packages failed to compile
echo "Summary:"
for package in "${packages[@]}"; do
    if [ ${status[$package]} -eq 0 ]; then
        echo "$package compiled successfully"
    else
        echo "Error: $package compilation failed"
    fi
done
