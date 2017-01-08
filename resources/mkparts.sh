#!/bin/bash
# mkpart <device> <sizeMB> <squashfs> <extra_part_fs>
# ex: mkparts.sh ARCHX.img 100 rootfs.s
# TODO/ make fixed squash size possible
export LC_ALL=C
rootfs=$(mktemp -d)

if [ -e /usr/share/installer ] ; then
    . /usr/share/installer/instlib.sh
else
    . ./resources/instlib.sh
fi

[ "x$DISKLABEL" = "x" ] && DISKLABEL=LINUX
echo "DISKLABEL: $DISKLABEL"

function clean_exit() {
    sudo umount $rootfs/storage 2>/dev/null
    sudo umount $rootfs/boot 2>/dev/null
    sudo umount $rootfs 2>/dev/null
    sudo rmdir $rootfs 2>/dev/null
    sudo losetup -d $loop 2>/dev/null
    exit $1
}

DISK=$1
FS1=fat32
SZ1=$2
SQ=$3

if [ -z $SQ ]; then
    echo "Syntax: $0 <image or device> <boot_part_size> <squash_image>"
    exit 1
fi

tot_size=$(parted $DISK --script print |grep '^Disk /' | cut -d: -f2)

if [[ "$SQ" == "/dev/"* ]]; then # partition
    sq_size=$(( $(df $SQ | grep ^/ | awk '{print $2}') / 1024 + 1 ))
else # file
    sq_size=$(( $(ls -l $SQ|cut -d' ' -f5) / 1048576 + 1 ))
fi

echo "############################################################## wipe disk "
wipefs --force -a $DISK
echo "############################################################## make disk structure "

call_fdisk $DISK n p 1 - +${SZ1}M t ef n p 2 - +${sq_size}M n - - - - a 1 w || clean_exit 1

sudo partprobe
loop=$(sudo losetup -P -f --show $DISK)
sudo partprobe

echo "############################################################## create BOOT/EFI partition "
mkfs.fat -n $DISKLABEL ${loop}p1 || clean_exit 1
echo "############################################################## copy ROOT filesystem"
dd if=$SQ of=${loop}p2 bs=100M || clean_exit 1
# TODO: alternative: mkfs + unsquashfs
# - remove initcpio hook (rolinux) + regen
# - regen grub-conf
echo "############################################################## create data partition"
mkfs.ext4 -F ${loop}p3 || clean_exit 1

sudo mount ${loop}p2 $rootfs
sudo mount ${loop}p1 $rootfs/boot
sudo mount ${loop}p3 $rootfs/storage

if [ -d ROOT ]; then
    UPDATE_EFI=
    RSRC=ROOT/boot/rootfs.default
    sudo cp -ar ROOT/boot/* $rootfs/boot
    INSTALL_SECURE_BOOT=1
else
    UPDATE_EFI=1
    RSRC=/boot/rootfs.default
    sudo cp -ar /boot/{grub,EFI} $rootfs/boot
    sudo cp -ar /boot/*inux* $rootfs/boot
fi
sudo tar xf $RSRC -C $rootfs/storage

install_grub "${loop}" "$rootfs/boot" $DISKLABEL "$UPDATE_EFI"

echo "FINISHED"
clean_exit 0
