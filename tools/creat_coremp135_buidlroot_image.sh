#!/bin/bash
# SPDX-FileCopyrightText: 2024 M5Stack Technology CO LTD
#
# SPDX-License-Identifier: MIT
check_package_existence() {
    local package=$1
    if apt-cache show "$package" > /dev/null 2>&1; then
        echo "The software package $package is available in the apt repository."
        return 0
    else
        echo "The software package $package is not available in the apt repository."
        return 1
    fi
}


clone_buildroot() {
    [ -d 'CoreMP135_buildroot' ] || git clone https://github.com/m5stack/CoreMP135_buildroot.git
    [ -d 'CoreMP135_buildroot' ] || { echo "not found CoreMP135_buildroot" && exit -1; }
    pushd CoreMP135_buildroot
    [ -f 'dl.7z' ] || wget https://github.com/m5stack/CoreMP135_buildroot/releases/download/v1.0.1/dl.7z
    [ -d 'dl' ] || 7z x dl.7z -odl
    [ -d 'dl' ] || { echo "not found dl" && exit -1; }
    popd
}

make_buildroot() {
    cd CoreMP135_buildroot
    make BR2_EXTERNAL=../../.. m5stack_coremp135_515_defconfig
    [[ -v ROOTFS_SIZE ]] && sed -i 's/^\(BR2_TARGET_ROOTFS_EXT2_SIZE=\).*$/\1"'"${ROOTFS_SIZE}"'"/' .config
    make -j `nproc`
}



package_lists=("debianutils" "sed" "make" "binutils" "build-essential" "gcc" "g++" "bash" "patch" "gzip" "bzip2" "perl" "tar" "cpio" "unzip" "rsync" "file" "bc" "git" "cmake" "p7zip-full" "python3" "python3-pip" "expect" "libssl-dev" "qemu-user-static")

for item in "${package_lists[@]}"; do
    check_package_existence "$item"
    [ "$?" == "0" ] || sudo apt install $item -y
done


fun_lists=("clone_buildroot" "make_buildroot")

[ -d 'build_coremp135_buidlroot' ] || mkdir build_coremp135_buidlroot
pushd build_coremp135_buidlroot
for item in "${fun_lists[@]}"; do
    $item
    ret=$?
    [ "$ret" == "0" ] || exit $ret
done
popd

