#!/bin/sh
DISKLABEL="ARCHX"
#USE_SQUASH=1
#REUSE=1
USE_EFI_PART=1
MARGIN=20 # percentage
FSTYPE="xfs"
FSOPTS="-f"

#FSTYPE="ext4"
#FSOPTS="-F"


TGT=/mnt/install_target
MODZ="normal search chain search_fs_uuid search_label search_fs_file part_gpt part_msdos fat usb ntfs ntfscomp ext2 btrfs xfs"

mkdir "$TGT"
LC_ALL=C fdisk -l 2>/dev/null | sed -n '/^Disk \// s/,.*// p' | grep -v loop| sort

w_fdisk() {
	fdisk "$IDISK" >/dev/null || oops
}

while [ ! -e "$IDISK" ]; do
    echo -n "Type path (/dev/...) of device to erase: "
    read IDISK
done

REQ_SZ=$(du -s /boot | cut -f1) # /boot size

# Create an EFI-compatible partition
if [ -z "$USE_EFI_PART" ]; then
    USE_EFI_PART=
else
    USE_EFI_PART="t\nef\n"
fi

oops() {
    echo "ERROR !!!"
    sleep 5
}

make_part() {
    PARTNO=$1
    SIZE=$2
    BOOT=$3

    [ -n "$BOOT" ] && SUFFIX="${USE_EFI_PART}a\n" || SUFFIX=
    [ -n "$SIZE" ] && SIZE="+$SIZE" || SIZE=

    echo "n\np\n$PARTNO\n\n${SIZE}\n${SUFFIX}w" | w_fdisk
}

# INSTALL
if [ -z "$REUSE" ]; then

    # PREPARE PARTITIONS
    dd if=/dev/zero of=$IDISK bs=1k count=1 # clear MBR

    if [ -n "$USE_SQUASH" ]; then # Single partition = /boot

        make_part 1 $(( $REQ_SZ * 1$MARGIN / 100000 ))M bootable || oops
        sync
        mkdosfs -F 32 -n $DISKLABEL ${IDISK}1 || oops

        mount ${IDISK}1 "$TGT" || oops
        cp -ar /boot/. "$TGT" || oops
        grub-install --target x86_64-efi --modules "$MODZ linux linux16 video" --efi-directory  "$TGT" ${IDISK}
        grub-install --target i386-pc    --modules "$MODZ"                     --boot-directory "$TGT" ${IDISK}
    else 
        TOT_SIZE=$(LC_ALL=C fdisk -l $IDISK --bytes | sed -En '/^Disk / s/.*, (.*) bytes.*/\1/ p')
        HOME_LIMIT=15000000000
        test  "11811160064" -gt "$TOT_SIZE" && (echo "Not enough space for this installation type, try another" ; exit)
        test  "$HOME_LIMIT" -gt "$TOT_SIZE" && SMALL_STORAGE=1

        make_part 1 100M bootable
        make_part 2 10G
        if [ -z "$SMALL_STORAGE" ]; then
            make_part 3
        fi
        sync
        mkdosfs -F 32 -n BOOTPART ${IDISK}1 || oops
        mkfs.${FSTYPE} ${FSOPTS} -L OSPART ${IDISK}2 || oops
        if [ -z "$SMALL_STORAGE" ]; then
            mkfs.${FSTYPE} ${FSOPTS} -L USERPART ${IDISK}3 || oops
        fi

        mount ${IDISK}2 "$TGT" || oops
        mkdir "$TGT/home" 
        if [ -z "$SMALL_STORAGE" ]; then
            mount ${IDISK}3 "$TGT/home"
        fi
        mkdir "$TGT/boot" && mount ${IDISK}1 "$TGT/boot"

        unsquashfs -fr 64 -da 64 -f -d "$TGT" /boot/rootfs.s || oops

        echo "Last configuration steps"

        tar xf /boot/rootfs.default --strip-components 3 -C "$TGT/home" || oops
		rm "$TGT/home/"*/*.sh

        # Build initcpio
		genfstab -U "$TGT" > "$TGT/etc/fstab" || oops
        sed '/# MOVABLE PATCH/,$ d' /etc/mkinitcpio.conf > "$TGT/etc/mkinitcpio.conf"
        cp -ra /boot/grub "$TGT/boot"
        cp -a /boot/*linux "$TGT/boot"        
        arch-chroot "$TGT" mkinitcpio -p linux || oops
		# Grub install
		arch-chroot "$TGT" grub-install --target x86_64-efi --modules "$MODZ linux linux16 video" --efi-directory  "/boot" ${IDISK}
        arch-chroot "$TGT" grub-install --target i386-pc    --modules "$MODZ"                     --boot-directory "/boot" ${IDISK}
        arch-chroot "$TGT" grub-mkconfig -o /boot/grub/grub.cfg || oops
    fi
    umount "$TGT"
fi
