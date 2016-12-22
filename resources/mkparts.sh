#!/bin/bash
# mkpart <device> <sizeMB> <squashfs> <extra_part_fs>
# ex: mkparts.sh ARCHX.img 100 rootfs.s
# TODO/ make fixed squash size possible
export LC_ALL=C
rootfs=$(mktemp -d)

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
    echo "Syntax: $0 <image or device> <boot_part_size> <squash_image> <extra fs>"
    exit 1
fi

tot_size=$(parted $DISK --script print |grep '^Disk /' | cut -d: -f2)

if [[ "$SQ" == "/dev/"* ]]; then # partition
    sq_size=$(( $(df $SQ | grep ^/ | awk '{print $2}') / 1024 + 1 ))
else # file
    sq_size=$(( $(ls -l $SQ|cut -d' ' -f5) / 1048576 + 1 ))
fi

dd conv=notrunc if=/dev/zero of=$DISK bs=512 count=1 # clear MBR

echo -e 'n\np\n1\n\n+'$SZ1'M\nt\nef\nn\np\n2\n\n+'$sq_size'M\nn\n\n\n\n\na\n1\nw\n' | fdisk $DISK || clean_exit 1

sudo partprobe
loop=$(sudo losetup -P -f --show $DISK)
sudo partprobe

sudo mkfs.fat -n $DISKLABEL ${loop}p1 || clean_exit 1
echo " SQUASH ####################################################"
sudo dd if=$SQ of=${loop}p2 bs=100M || clean_exit 1
# TODO: alternative: mkfs + unsquashfs
# - remove initcpio hook (rolinux) + regen
# - regen grub-conf
echo " EXT4 ####################################################"
sudo mkfs.ext4 -F ${loop}p3 || clean_exit 1


sudo mount ${loop}p2 $rootfs
sudo mount ${loop}p1 $rootfs/boot
sudo mount ${loop}p3 $rootfs/storage

if [ -d ROOT ]; then
    RSRC=ROOT/boot/rootfs.default
    sudo cp -ar ROOT/boot/* $rootfs/boot
    INSTALL_SECURE_BOOT=1
    EFI_OPTS="--no-nvram"
else
    RSRC=/boot/rootfs.default
    sudo cp -ar /boot/grub $rootfs/boot
    sudo cp -ar /boot/EFI $rootfs/boot
    sudo cp -ar /boot/*inux* $rootfs/boot
fi
sudo tar xf $RSRC -C $rootfs/storage

MOD="normal search chain search_fs_uuid search_label search_fs_file part_gpt part_msdos fat usb"

sudo mkdir "$rootfs/boot/boot"

sudo grub-install --target x86_64-efi --recheck --removable --compress=xz --modules "$MOD" --boot-directory "$rootfs/boot" --efi-directory "$rootfs/boot" --bootloader-id "$DISKLABEL" $EFI_OPTS
sudo grub-install --target i386-pc    --recheck --removable --compress=xz --modules "$MOD" --boot-directory "$rootfs/boot" $loop

sudo sed -i "s/ARCHX/$DISKLABEL/g" "$rootfs/boot/grub/grub.cfg"
sudo sed -i "s/ARCHINST/$DISKLABEL/g" "$rootfs/boot/grub/grub.cfg"

if [ -n "$INSTALL_SECURE_BOOT" ]; then
    sudo cp secureboot/{PreLoader,HashTool}.efi "$rootfs/boot/EFI/BOOT/"
    sudo mv "$rootfs/boot/EFI//BOOT/BOOTX64.EFI"    "$rootfs/boot/EFI/BOOT/loader.efi" # loader = grub
    sudo mv "$rootfs/boot/EFI//BOOT/PreLoader.efi"  "$rootfs/boot/EFI/BOOT/BOOTX64.EFI" # default loader = preloader
fi

echo "FINISHED"
clean_exit 0
