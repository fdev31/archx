#!/bin/bash
DISKLABEL="ARCHX"
#USE_SQUASH=1
REUSE=1
USE_EFI_PART=1
MARGIN=20 # percentage
FSTYPE="xfs"
FSOPTS="-f"

#FSTYPE="ext4"
#FSOPTS="-F"

# 1=clone to another device, 2=install archlinux only, 3=install to FAT partition
# in all modes the but 2, no RW partition is made by default, but it can be created later by user

INSTALL_MODE=3


TGT=/mnt/install_target
MODZ="normal search chain search_fs_uuid search_label search_fs_file part_gpt part_msdos fat usb ntfs ntfscomp ext2 btrfs xfs"

INSTALLATION_MEDIA=$(mount | grep ' /boot ')
INSTALLATION_MEDIA=${INSTALLATION_MEDIA%% *}
INSTALLATION_MEDIA=${INSTALLATION_MEDIA:0:-1}


mkdir "$TGT"

w_fdisk() {
	fdisk "$IDISK" >/dev/null || oops
}

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

install_core() {
    local D=$1
    local T=$2
    cp -ar /boot/. "$TGT" || oops
    grub-install --target x86_64-efi --modules "$MODZ"  --efi-directory  "$T" "$D"
    grub-install --target i386-pc    --modules "$MODZ"  --boot-directory "$T" "$D"
}

# INSTALL
if [ "$INSTALL_MODE" -lt 3 ]; then

    LC_ALL=C fdisk -l 2>/dev/null | sed -n '/^Disk \// s/,.*// p' | grep -v loop| sort
    while [ ! -e "$IDISK" ]; do
        echo -n "Type path (/dev/...) of device to erase: "
        read IDISK
    done

    # PREPARE PARTITIONS
    dd if=/dev/zero of=$IDISK bs=1k count=1 # clear MBR

    if [ "$INSTALL_MODE" = "1" ]; then # Single partition = /boot

        make_part 1 $(( $REQ_SZ * 1$MARGIN / 100000 ))M bootable || oops
        sync
        mkdosfs -F 32 -n $DISKLABEL ${IDISK}1 || oops

        mount ${IDISK}1 "$TGT" || oops
        install_core ${IDISK}1 "$TGT" || oops

    else  # kind of "standard" arch install
        TOT_SIZE=$(LC_ALL=C fdisk -l $IDISK --bytes | sed -En '/^Disk / s/.*, (.*) bytes.*/\1/ p')
        test  "10000000000" -gt "$TOT_SIZE" && (echo "Not enough space for this installation type, try another" ; exit)
        BOOT_PART_SIZE="100M"
        ROOT_PART_SIZE="10G"
        if [ "15000000000" -gt "$TOT_SIZE" ]; then #  if < 15G : NO HOME PARTITION
            SMALL_STORAGE=1
            BOOT_PART_SIZE="100M"
            ROOT_PART_SIZE="" # single partition: no limits
        fi

        if [ "50000000000" -lt "$TOT_SIZE" ]; then # > 50GB
            if [ "100000000000" -lt "$TOT_SIZE" ]; then # > 100GB
                BOOT_PART_SIZE="500M"
                ROOT_PART_SIZE="50G"
            else #  50 < x < 100
                BOOT_PART_SIZE="200M"
                ROOT_PART_SIZE="30G"
            fi
        fi

        make_part 1 $BOOT_PART_SIZE bootable
        make_part 2 $ROOT_PART_SIZE
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
		arch-chroot "$TGT" grub-install --target x86_64-efi --modules "$MODZ" --efi-directory  "/boot" "${IDISK}"
        arch-chroot "$TGT" grub-install --target i386-pc    --modules "$MODZ" --boot-directory "/boot" "${IDISK}"
        arch-chroot "$TGT" grub-mkconfig -o /boot/grub/grub.cfg || oops
        umount "$TGT/home" 2>/dev/null
        umount "$TGT/boot" 2>/dev/null
    fi
else # reuse existing partition
    PARTITIONS=$(fdisk -l |grep '^/dev' | sed 's/*/ /' | awk '{print $1 ":" $5}' |grep -v 'M$')
    for PART in $PARTITIONS ; do
        if [ ${PART:0:8} = ${INSTALLATION_MEDIA} ]; then
            continue
        fi
        PART_INFO=$(blkid -o value -s LABEL -s TYPE ${PART%:*} | sed 'N; s/\n/ /' )
        case $PART_INFO in
            *" "*)
                PART_INFO=$(echo $PART_INFO | sed -E 's/ / TYPE=/ ;  s/^/LABEL=/ ')
                ;;
            *)
               PART_INFO=$(echo $PART_INFO | sed -E 's/^/TYPE=/')
               ;;
       esac
       echo -e "${PART%:*}\t${PART#*:}\t${PART_INFO}"
    done

    while [ ! -e "$SQUASH_PART" ]; do
        echo -n "Type path (/dev/...) of the logical device you want to install to: "
        read SQUASH_PART
    done
    mount ${SQUASH_PART} "$TGT" || oops
    install_core ${SQUASH_PART:0:-1} "$TGT" || oops
fi

umount "$TGT"
