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
#echo "############################################################## copy ROOT filesystem"
#dd if=$SQ of=${loop}p2 bs=100M || clean_exit 1
# TODO: alternative: mkfs + unsquashfs
# - remove initcpio hook (rolinux) + regen
# - regen grub-conf
echo "############################################################## create data partition"
mkfs.ext4 -F ${loop}p3 || clean_exit 1

mount ${loop}p2 $rootfs
mount ${loop}p1 $rootfs/boot

unsquashfs -d $rootfs $SQ
cp -ar /boot/{grub,EFI} $rootfs/boot
cp -ar /boot/*inux* $rootfs/boot

tar xvf /boot/rootfs.default -C "$rootfs" './ROOT' --wildcards --wildcards-match-slash --strip-components 2
strip_end "# MOVABLE PATCH" $rootfs/etc/mkinitcpio.conf
rm -f $rootfs/etc/fstab
genfstab -U $rootfs >> $rootfs/etc/fstab
arch-chroot $rootfs grub-mkconfig -o /boot/grub/grub.cfg
arch-chroot grub-install

echo "FINISHED"
clean_exit 0
