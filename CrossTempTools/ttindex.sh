#!/bin/bash

# List of packages to compile
packages=("m4" "ncurses" "bash" "coreutils" "diffutils" "file" "findutils" "gawk" "grep" "gzip" "make" "patch" "sed" "tar" "xz" "binutils-pass2" "gcc-pass2")

# Initialize compilation status for each package
declare -A status
for package in "${pack]}"; do
    status[$package]=0
done

# Compile each package using its compilation script and update compilation status
for package in "${pack]}"; do
    echo "Compiling $package"
    case $package in
        "m4")
            echo "Installing M4 (1/17)"
            sleep 1
            . /home/$user/lfs-install/CrossTempTools/compile-m4.sh
            ;;
        "ncurses")
            echo "Installing Ncurses (2/17)"
            sleep 1
            . /home/$user/lfs-install/CrossTempTools/compile-ncurses.sh
            ;;
        "bash")
            echo " Installing Bash (3/17)"
            sleep 1
            . /home/$user/lfs-install/CrossTempTools/compile-bash.sh
            ;;
        "coreutils")
            echo "Installing Coreutils (4/17)"
            sleep 1
            . /home/$user/lfs-install/CrossTempTools/compile-coreutils.sh
            ;;
        "diffutils")
            echo "Installing Diffutils (5/17)"
            sleep 1
            . /home/$user/lfs-install/CrossTempTools/compile-diffutils.sh
            ;;
       "file")
            echo "Installing File (6/17)"
            sleep 1
            . /home/$user/lfs-install/CrossTempTools/compile-file.sh
            ;;
        "findutils")
            echo "Installing Findutils (7/17)"
            sleep 1
            . /home/$user/lfs-install/CrossTempTools/compile-findutils.sh
            ;;
        "gawk")
            echo "Installing Gawk (8/17)"
            sleep 1
            . /home/$user/lfs-install/CrossTempTools/compile-gawk.sh
            ;;
        "grep")
            echo "Installing Grep (9/17)"
            sleep 1
            . /home/$user/lfs-install/CrossTempTools/compile-grep.sh
            ;;
        "gzip")
            echo "Installing Gzip (10/17)"
            sleep 1
            . /home/$user/lfs-install/CrossTempTools/compile-gzip.sh
            ;;
       "make")
            echo "Installing Make (11/17)"
            sleep 1
            . /home/$user/lfs-install/CrossTempTools/compile-make.sh
            ;;
        "patch")
            echo "Installing Patch (12/17)"
            sleep 1
            . /home/$user/lfs-install/CrossTempTools/compile-patch.sh
            ;;
        "sed")
            echo "Installing Sed (13/17)"
            sleep 1
            . /home/$user/lfs-install/CrossTempTools/compile-sed.sh
            ;;
        "tar")
            echo "Installing Tar (14/17)"
            sleep 1
            . /home/$user/lfs-install/CrossTempTools/compile-tar.sh
            ;;
        "xz")
            echo "Installing Xz (15/17)"
            sleep 1
            . /home/$user/lfs-install/CrossTempTools/compile-xz.sh
            ;;
       "binutils-pass2")
            echo "Installing Binutils pt2 (16/17)"
            sleep 1
            . /home/$user/lfs-install/CrossTempTools/compile-binutils-pass2.sh
            ;;
        "gcc-pass2")
            echo "Installing GCC pt2 (17/17)"
            sleep 1
            . /home/$user/lfs-install/CrossTempTools/compile-gcc-pass2.sh
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
for package in "${pack]}"; do
    if [ ${status[$package]} -eq 0 ]; then
        echo "$package compiled successfully"
    else
        echo "Error: $package compilation failed"
    fi
done
