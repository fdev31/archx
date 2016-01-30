#!/bin/bash

DEPS="grub arch-install-scripts sudo dosfstools squashfs-tools xz"

pacman -Qq $DEPS > /dev/null || exit "Required packages: $DEPS"

if [ ! -e configuration.sh ]; then
    echo "This script must be executed from its own original folder"
    exit 1
fi

source configuration.sh
source strapfuncs.sh

SECT_SZ=512
LO_DEV=''
ROOT_DEV=''

function run_hooks() {
    step "Executing $1 hooks..."
    for hook in ./hooks/$PROFILE/$1/*.sh; do
        step2 "HOOK $hook"
        sudo $hook
    done
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

function run_install_hooks() {
    step "Triggering install hooks"
    run_hooks pre-install
    run_hooks install
    run_hooks post-install
}

function make_squash_root() {
    step "Cleaning FS & building SQUASHFS"
    IF=../ignored.files
    pushd "$R" || exit -2
        sudo find boot/* > $IF
        sudo find var/cache/ -type f >> $IF
        sudo mksquashfs . "$SQ" -ef $IF -comp $COMPRESSION_TYPE -no-exports -noappend -no-recovery
    popd
    rm ignored.files
}

function grub_install() {
    F="$1"
    D="$2"
    BIOS_MOD="part_gpt part_msdos fat usb"
    sudo grub-install --recheck --target x86_64-efi --efi-directory "$F" --removable --no-nvram "$D"
    sudo grub-install --recheck --target i386-pc --boot-directory "$F" --removable --modules "$BIOS_MOD" "$D"
}

function grub_on_img() {
    step "Installing bootloader"
    ROOT_DEV=$(losetup --show -f "$D")
    grub_install "$T/" "$ROOT_DEV"
    losetup -d "$ROOT_DEV"
}

function mount_part0() {
    OFFSET=$(($SECT_SZ * $(fdisk -lu "$D" |grep "^$D" |awk '{print $3}') ))
    LO_DEV=$(losetup -o "$OFFSET" --show -f "$LO_DEV" "$D")

    # Make final disk with boot + root
    T=tmpmnt
	sudo rm -fr "$T" 2> /dev/null
    sudo mkdir "$T"
    sudo mount "$LO_DEV" "$T"
}

function umount_part0() {
    sudo umount "./$T"
    sudo rmdir "$T"
    sudo losetup -d "$LO_DEV"
}

function make_disk_image() {
    # computed disk size, in MB
    CDS=$(echo $(stat -c '%s' "${SQ}") / 1000000.0 + $(du -s "${R}/boot" | cut -f1) / 1000.0  + "${DISK_MARGIN}" | bc)

    step "Creating disk image (${CDS} MB, ${DISK_MARGIN} reserved)"

    dd if=/dev/zero "of=${D}" bs=1M count=${CDS}

    #  Make partitions
    echo -e "n\np\n1\n\n\nt\nef\na\nw" | LC_ALL=C fdisk "$D" >/dev/null 

    step2 "Creating FAT32 filesystem"
    echo $(($SECT_SZ * $(fdisk -lu "$D" |grep "^$D" |awk '{print $3}') ))
    OFFSET=$(($SECT_SZ * $(fdisk -lu "$D" |grep "^$D" |awk '{print $3}') ))
    echo losetup -o "$OFFSET" --show -f "$D"
    LO_DEV=$(losetup -o "$OFFSET" --show -f "$D")
    echo mkdosfs -F 32 -n "$DISKLABEL" "$LO_DEV"
    mkdosfs -F 32 -n "$DISKLABEL" "$LO_DEV"

    step "Populating filesystem"
    # Make final disk with boot + root
    T=tmpmnt
	sudo rm -fr "$T" 2> /dev/null
    sudo mkdir "$T"
    sudo mount "$LO_DEV" "$T"

    sudo cp -ar "$R/boot/"* "$T/"
    if [ ! -d "$T/EFI" ]; then
        sudo mkdir "$T/EFI/"
    fi
    step2 "Copying ROOTFS (can take a while)..."
    sudo cp "$SQ" "$T/"

    step2 "Syncing."
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

case "$PARAM" in
    run*)
        exec qemu-system-x86_64 -m 1024 -enable-kvm -drive file=$D,format=raw
        # if GRUB is broken for you, try this one:
#        qemu-system-x86_64 -m 1024 -enable-kvm -drive file=$D,format=raw -kernel $R/boot/vmlinuz-linux -initrd $R/boot/initramfs-linux.img -append root=LABEL=$DISKLABEL
        exit
        ;;
	ins*)
		shift # pop the first argument
        install_pkg "$*"
        exit
		;;
	shell*)
		sudo arch-chroot "$R"
        exit
		;;
    conf*)
        reconfigure
        make_squash_root
        exit
        ;;
    sq*):
        make_squash_root
        exit
        ;;
    d*)
        make_disk_image
        exit
        ;;
    up*)
        run_install_hooks
        make_squash_root
        make_disk_image
        exit
        ;;
    g*)
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
        sudo cp -ar "$R/boot/"* flute/ || exit 1
        step "Copying root (can take a while)..."
        sudo cp "$SQ" flute/ || exit 1
        step "Installing GRUB..."
        grub_install flute/ "${drive:0:-1}"
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
        run_install_hooks
        make_squash_root
        make_disk_image
        ;;
	*)
        echo "Usage: $0 <command> [options]"
        echo "Commands:"
        echo "       all: build the full system from scratch (RUN THIS FIRST)"
        echo "       run: runs QEMU emulator"
        echo "        up: re-create rootfs after a manual update (default)"
        echo "     shell: start a shell"
        echo "   install: install some package"
        echo "      conf: re-create ramdisk & rootfs"
        echo "    squash: re-create squash rootfs"
        echo "      disk: re-create disk image from current squash"
        echo "     flash: install rootfs to some USB drive & make it bootable"
        exit 0
esac

echo "Type \" $0 install <package name> \" to install a new package"
echo "or \" $0 up \" to rebuild the disk image"

