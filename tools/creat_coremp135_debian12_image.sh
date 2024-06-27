#!/bin/bash

[ -d 'build_coremp135_debian12' ] || mkdir -p build_coremp135_debian12/debian-minimal-armhf
export ROOTFS_SIZE="1024M"
./creat_coremp135_buidlroot_image.sh && cp build_coremp135_buidlroot/CoreMP135_buildroot/output/images/sdcard.img build_coremp135_debian12/
[ -f 'build_coremp135_debian12/sdcard.img' ] || { echo "not found sdcard.img" && exit -1; }

pushd build_coremp135_debian12
[ -f 'debian-12.1-minimal-armhf-2023-08-22.tar.xz' ] || wget https://rcn-ee.com/rootfs/eewiki/minfs/debian-12.1-minimal-armhf-2023-08-22.tar.xz
[ -f 'debian-12.1-minimal-armhf-2023-08-22.tar.xz' ] || { echo "not found debian-12.1-minimal-armhf-2023-08-22.tar.xz" && exit -1; }
[ -d 'debian-minimal-armhf' ] || mkdir debian-minimal-armhf
tar -xJf debian-12.1-minimal-armhf-2023-08-22.tar.xz -C debian-minimal-armhf

[ -d 'rootfs' ] || mkdir -p rootfs
sudo losetup -P /dev/loop258 sdcard.img
sleep 1
[ -e "/dev/loop258p5" ] || { echo "not found /dev/loop258p5" && exit -1; }
sudo mount /dev/loop258p5 rootfs

mkdir -p rootfs_overlay ;sudo cp rootfs/boot rootfs_overlay/ -a
mkdir -p rootfs_overlay/usr/lib ;sudo cp rootfs/lib/modules rootfs_overlay/usr/lib/ -a
mkdir -p rootfs_overlay/usr/lib ;sudo cp rootfs/lib/firmware rootfs_overlay/usr/lib/ -a

mkdir -p rootfs_overlay/usr/local/m5stack/bin ;sudo cp rootfs/usr/bin/tiny* rootfs_overlay/usr/local/m5stack/bin/ -a
mkdir -p rootfs_overlay/usr/local/m5stack/bin ;sudo cp rootfs/usr/bin/fbv rootfs_overlay/usr/local/m5stack/bin/ -a

mkdir -p rootfs_overlay/usr/local/m5stack/lib ;sudo cp rootfs/usr/lib/libtinyalsa* rootfs_overlay/usr/local/m5stack/lib/ -a
mkdir -p rootfs_overlay/usr/local/m5stack/lib ;sudo cp rootfs/usr/lib/libpng16* rootfs_overlay/usr/local/m5stack/lib/ -a
mkdir -p rootfs_overlay/usr/local/m5stack/lib ;sudo cp rootfs/usr/lib/libjpeg* rootfs_overlay/usr/local/m5stack/lib/ -a
mkdir -p rootfs_overlay/usr/local/m5stack/lib ;sudo cp rootfs/usr/lib/libgif* rootfs_overlay/usr/local/m5stack/lib/ -a

sudo rm rootfs/* -rf
sudo tar xf debian-minimal-armhf/debian-12.1-minimal-armhf-2023-08-22/armhf-rootfs-debian-bookworm.tar -C rootfs/

sudo cp --preserve=mode,timestamps -r rootfs_overlay/* rootfs/
sudo cp --preserve=mode,timestamps -r ../overlay_debian12/* rootfs/


sudo chroot rootfs/ /usr/bin/dpkg -i /var/gdisk_1.0.9-2.1_armhf.deb
sudo chroot rootfs/ /usr/bin/dpkg -i /var/network-manager_1.42.4-1_armhf.deb


sudo sync
sudo umount rootfs
sudo losetup -D /dev/loop258

date_str=`date +%Y%m%d`
image_name="M5_CoreMP135_debian12_$date_str.img"
mv sdcard.img $image_name

popd
echo "$image_name creat success!"
