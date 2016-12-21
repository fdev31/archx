#!/bin/bash
# mkpart <device> <sizeMB> <squashfs> <extra_part_fs>
# ex: mkparts.sh ARCHX.img 100 rootfs.s
# TODO/ make fixed squash size possible
export LC_ALL=C

DISKLABEL=LINUX

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
    echo "Syntax: $0 <image or device> <boot_part_size> <squash_image> <extra fs>"
    exit 1
fi

tot_size=$(parted $DISK --script print |grep '^Disk /' | cut -d: -f2)
sq_size=$(( $(ls -l $SQ|cut -d' ' -f5) / 1048576 + 1 ))

dd conv=notrunc if=/dev/zero of=$DISK bs=512 count=1 # clear MBR

echo -e 'n\np\n1\n\n+'$SZ1'M\nt\nef\nn\np\n2\n\n+'$sq_size'M\nn\n\n\n\n\na\n1\nw\n' | fdisk $DISK || clean_exit 1

sudo partprobe

loop=$(sudo losetup -P -f --show $DISK)
sudo mkfs.fat -n $DISKLABEL -F 32 ${loop}p1 || clean_exit 1
echo " SQUASH ####################################################"
sudo dd if=$SQ of=${loop}p2 bs=1M || clean_exit 1
echo " EXT4 ####################################################"
sudo mkfs.ext4 -F ${loop}p3 || clean_exit 1

rootfs=$(mktemp -d)

sudo mount ${loop}p2 $rootfs
sudo mount ${loop}p1 $rootfs/boot
sudo mount ${loop}p3 $rootfs/storage
tar xvf /boot/rootfs.default -C $rootfs/storage

if [ -d ROOT ]; then
    sudo cp -ar ROOT/boot/* $rootfs/boot
else
    sudo cp -ar /boot/grub $rootfs/boot
    sudo cp -ar /boot/EFI $rootfs/boot
    sudo cp -ar /boot/*inux* $rootfs/boot
fi

MOD="normal search chain search_fs_uuid search_label search_fs_file part_gpt part_msdos fat usb"

sudo mkdir "$rootfs/boot/boot"

sudo grub-install --target x86_64-efi --recheck --removable --compress=xz --modules "$MOD" --boot-directory "$rootfs/boot" --efi-directory "$rootfs/boot" --bootloader-id "$DISKLABEL" --no-nvram --force-file-id
sudo grub-install --target i386-pc    --recheck --removable --compress=xz --modules "$MOD" --boot-directory "$rootfs/boot" $loop

sudo sed -i "s/ARCHX/$DISKLABEL/g" "$rootfs/boot/grub/grub.cfg"

echo "FINISHED"
clean_exit 0
