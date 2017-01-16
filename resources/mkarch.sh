#!/bin/bash
# mkarch <device> <sizeMB> <squashfs> <extra_part_fs>
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

call_fdisk $DISK n p 1 - +${SZ1}M t ef n - - - - a 1 w || clean_exit 1

partprobe
loop=$(losetup -P -f --show $DISK)
partprobe

echo "############################################################## create BOOT/EFI partition "
mkfs.fat -n $DISKLABEL ${loop}p1 || clean_exit 1
echo "############################################################## create data partition"
mkfs.ext4 -F ${loop}p2 || clean_exit 1

mount ${loop}p2 "$rootfs"

mkdir "$rootfs/boot"
mount ${loop}p1 "$rootfs/boot"

mkdir $rootfs/boot/EFI

unsquashfs -f -fr 64 -da 64 -d $rootfs $SQ
cp -ar /boot/{grub,EFI} $rootfs/boot
cp -ar /boot/*inux* $rootfs/boot

tar xf /boot/rootfs.default -C "$rootfs" './ROOT' --wildcards --wildcards-match-slash --strip-components 2

# undo some changes / update confs
sudo sed -i "/^# MOVABLE PATCH/,$ d" $rootfs/etc/mkinitcpio.conf
rm -f $rootfs/etc/fstab
genfstab -U $rootfs >> $rootfs/etc/fstab
arch-chroot $rootfs grub-mkconfig -o /boot/grub/grub.cfg
arch-chroot $rootfs grub-install --boot-directory BOOT --target i386-pc ${loop}
arch-chroot $rootfs grub-install --efi-directory /boot/EFI --boot-directory /boot ${loop}

arch-chroot $rootfs mkinitcpio -p linux

rm -f $rootfs/lib/initcpio/hooks/rolinux
rm -f $rootfs/bin/installer-*.sh
rm -f $rootfs/bin/installer.py
rm -fr $rootfs/usr/share/installer

echo "FINISHED"
clean_exit 0
