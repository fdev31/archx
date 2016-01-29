#!/bin/bash

DEPS="grub arch-install-scripts sudo dosfstools squashfs-tools xz"

pacman -Qq $DEPS > /dev/null || exit "Required packages: $DEPS"

if [ ! -e configuration.sh ]; then
    echo "This script must be executed from its own original folder"
    exit 1
fi

source configuration.sh

SQUASH_OPTS="-comp xz -no-exports -noappend -no-recovery"
SECT_SZ=512

function run_hooks() {
    step "Executing $1 hooks..."
    for hook in ./hooks/$PROFILE/$1/*.sh; do
        echo "- $hook"
        sudo $hook
    done
}

function share_cache() {
    if ! mount | grep pacman ; then
        sudo mount --bind /var/cache/pacman/pkg "$R/var/cache/pacman/pkg"
    fi
}
function unshare_cache() {
    sudo umount "$R/var/cache/pacman/pkg"
}

function step() {
    echo -e "\\033[44m\\033[1m ------------[   $1   >\\033[0m\\033[49m"
}

function reset_rootfs() {
    step "Clear old rootfs"
    sudo rm -fr "$R" 2> /dev/null
    mkdir "$R"
}

function base_install() {
    step "Installing base packages & patch root files"
    # install packages
    sudo pacstrap -cd "$R" base
    # configure fstab
    sudo chown root.root "$R"
}

function reconfigure() {
    step "Re-generating RAMFS and low-level config" 
    run_hooks pre-mkinitcpio
    sudo arch-chroot "$R" mkinitcpio -p linux
}

function make_squash_root() {
    run_hooks pre-install
    run_hooks install
    run_hooks post-install
    step "Cleaning FS & building SQUASHFS"
    sudo rm $SQ 2> /dev/null
    (cd $R \
    && sudo find boot/* > ../ignored.files \
    && sudo find var/cache/ -type f >> ../ignored.files \
    && sudo mksquashfs . ../$SQ -ef ../ignored.files $SQUASH_OPTS)
    rm ignored.files
}

function grub_install() {
    F=$1
    D=$2
    BIOS_MOD="part_gpt part_msdos fat usb"
    sudo grub-install --recheck --target x86_64-efi --efi-directory $F --removable --no-nvram $D
    sudo grub-install --recheck --target i386-pc --boot-directory $F --removable --modules "$BIOS_MOD" $D
}

function grub_on_img() {
    step "Installing bootloader"
    root_dev=$(losetup --show -f $root_dev $D)
    grub_install $T/ $root_dev
    losetup -d $root_dev
}

function mount_part0() {
    offset=$(($SECT_SZ * $(fdisk -lu $D |grep ^$D |awk '{print $3}') ))
    lo_dev=$(losetup -o $offset --show -f $lo_dev $D)

    # Make final disk with boot + root
    T=tmpmnt
	sudo rm -fr $T 2> /dev/null
    sudo mkdir $T
    sudo mount $lo_dev $T
}

function umount_part0() {
    sudo umount ./$T
    sudo rmdir $T
    sudo losetup -d $lo_dev
}

function make_disk_image() {
    # computed disk size, in MB
    str="$(stat -c '%s' $SQ) / 1000000.0 + $(du -s $R/boot | cut -f1) / 1000.0  + $DISK_MARGIN"
    cds=$(echo $str| bc)
    step "Creating disk image ($cds MB, $DISK_MARGIN reserved)"
    dd if=/dev/zero of=$D bs=1M count=$cds

    #  Make partitions
    echo -e "n\np\n1\n\n\nt\nef\na\nw" | LC_ALL=C fdisk $D >/dev/null 

    step "Creating FAT32 filesystem"
    offset=$(($SECT_SZ * $(fdisk -lu $D |grep ^$D |awk '{print $3}') ))
    lo_dev=$(losetup -o $offset --show -f $lo_dev $D)
    mkdosfs -F 32 -n $DISKLABEL $lo_dev

    step "Populating filesystem"
    # Make final disk with boot + root
    T=tmpmnt
	sudo rm -fr $T 2> /dev/null
    sudo mkdir $T
    sudo mount $lo_dev $T

    sudo cp -ar $R/boot/* $T/
    if [ ! -d $T/EFI ]; then
        sudo mkdir $T/EFI/
    fi
    step "Copying ROOTFS (can take a while)..."
    sudo cp $SQ $T/

    step "Syncing."
    sudo sync
    step "Grub..."
    grub_on_img

    umount_part0
}

# MAIN

PARAM="$1"

if [ -z "$PARAM" ]; then
    if [ ! -d "$R" ]; then
        PARAM="all"
    else
        PARAM="up"
    fi
fi

case $PARAM in
    run*)
        qemu-system-x86_64 -m 1024 -enable-kvm -drive file=$D,format=raw -kernel $R/boot/vmlinuz-linux -initrd $R/boot/initramfs-linux.img -append root=LABEL=$DISKLABEL
        exit
        ;;
	ins*)
		shift # pop the first argument
        if [ -e $R/bin/yaourt ]; then
            PKGMGR=yaourt
        else
            PKGMGR=pacman
        fi
		echo "$PKGMGR --needed $*"
        share_cache
        sudo $PKGMGR -r "$R" --needed $*
        unshare_cache
        exit
		;;
	shell*)
		sudo arch-chroot $R
        exit
		;;
    conf*)
        reconfigure
        make_squash_root
        exit
        ;;
    up*)
        make_squash_root
        make_disk_image
        exit
        ;;
    grub)
        mount_part0
        grub_on_img
        umount_part0
        exit
        ;;
    flash)
		shift # pop the first argument
        drive=$1
        mkdir flute 2>/dev/null
        sudo mount $drive flute || exit 1
        step "Copying boot..."
        sudo cp -ar $R/boot/* flute/ || exit 1
        step "Copying root (can take a while)..."
        sudo cp $SQ flute/ || exit 1
        step "Installing GRUB..."
        grub_install flute/ ${drive:0:-1}
        df -h flute
        step "Syncing."
        sudo umount ./flute
        sudo sync
        sudo rm -fr flute
        exit
        ;;
    all*)
        reset_rootfs
        base_install
        reconfigure
        make_squash_root
        make_disk_image
        ;;
	*)
		echo "Usage: $0 <command> [options]"
		echo "Commands:"
		echo "     shell: start a shell"
		echo "   install: install some package"
		echo "      conf: re-create ramdisk & rootfs after a manual update"
		echo "        up: re-create rootfs after a manual update"
		echo "       all: build the full system from scratch (RUN THIS FIRST)"
		echo "       run: runs QEMU emulator"
		echo "     flash: update a DOS formated partition"
		exit 0
esac

echo "Type \" $0 install <package name> \" to install a new package"
echo "or \" $0 up \" to rebuild the disk image"

