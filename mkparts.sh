#!/bin/sh
# mkpart <device> <sizeMB> <squashfs> <extra_part_fs>
# ex: mkparts.sh ARCHX.img 100 rootfs.s jfs
# TODO/ make fixed squash size possible
export LC_ALL=C

DISK=$1
FS1=fat32
SZ1=$2
SQ=$3
FS2=$4

tot_size=$(parted $DISK --script print |grep '^Disk /' | cut -d: -f2)
sq_size=$(( $(ls -l $SQ|cut -d' ' -f5) / 1000000 ))

dd conv=notrunc if=/dev/zero of=$DISK bs=512 count=1 # clear MBR

P="parted $DISK --script"
$P mklabel gpt
$P mkpart primary $FS1 0 2
$P mkpart primary $FS1 2 $SZ1
$P set 1 bios_grub on
$P set 2 boot on

o2=$(( $SZ1 + $sq_size ))

$P mkpart primary ${SZ1}MB ${o2}MB

$P mkpart primary $FS2 ${o2}MB '100%'
$P align-check min 1

echo -e "r\nh\n1 2 3 4\ny\n\ny\n\nn\n\nn\nw\ny\n" | gdisk $DISK

$P print

loop=$(sudo losetup -f --show $DISK)
sudo mkfs.fat -F 32 ${loop}p2
sudo dd if=$SQ of=${loop}p3 bs=1M
sudo mkfs.jfs ${loop}p4

rootfs=$(mktemp -d)
#bootfs=$(mktemp -d)
#persistfs=$(mktemp -d)

sudo mount ${loop}p3 $rootfs
sudo mount ${loop}p2 $rootfs/boot
#sudo mount ${loop}p3 $persistfs

sudo cp -ar ROOT/boot/* $rootfs/boot

BIOS_MOD="normal search chain search_fs_uuid search_label search_fs_file part_gpt part_msdos fat usb ntfs ntfscomp"
DISKLABEL=LINUX
sudo grub-install --target x86_64-efi --efi-directory "$rootfs/boot/" --removable --modules "$BIOS_MOD linux linux16 video" --bootloader-id "$DISKLABEL" --no-nvram --force-file-id
sudo grub-install --target i386-pc --boot-directory "$rootfs/boot" --removable --modules "$BIOS_MOD" $loop



sudo umount $rootfs/boot
sudo umount $rootfs
sudo rmdir $rootfs

sudo losetup -d $loop
