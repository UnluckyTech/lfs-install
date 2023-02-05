            echo "Creating Required Directories"
            sleep 1
            mkdir -pv $LFS/{etc,var} $LFS/usr/{bin,lib,sbin}

            for i in bin lib sbin; do
            ln -sv usr/$i $LFS/$i
            done

            case $(uname -m) in
            x86_64) mkdir -pv $LFS/lib64 ;;
            esac
            mkdir -pv $LFS/tools
            echo "Adding LFS User"
            groupadd lfs
            useradd -s /bin/bash -g lfs -m -k /dev/null lfs
            echo "Enter lfs password"
            read lfspass
            ( echo $lfspass ; echo $lfspass ) | passwd lfs
            chown -v lfs $LFS/{usr{,/*},lib,var,etc,bin,sbin,tools}
            case $(uname -m) in
            x86_64) chown -v lfs $LFS/lib64 ;;
            esac
            echo "You will now log into lfs"
            su - lfs