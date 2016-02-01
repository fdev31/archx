#!/bin/bash

DEPS="grub arch-install-scripts sudo dosfstools squashfs-tools xz"

pacman -Qq $DEPS > /dev/null || exit "Required packages: $DEPS"

if [ ! -e configuration.sh ]; then
    echo "This script must be executed from its own original folder"
    exit 1
fi

source ./configuration.sh
source ./strapfuncs.sh
source ./distrib/${DISTRIB}.sh

if [ -n "$LIVE_SYSTEM" ] && [[ "$PROFILES" != *flashdisk ]] ; then
    PROFILES="${PROFILES} flashdisk"
fi

SECT_SZ=512
LO_DEV=''
ROOT_DEV=''

HOOK_BUILD_FLAG=0

function run_hooks() {
    if [ $HOOK_BUILD_FLAG -eq 0 ]; then
        # BUILD CURRENT HOOKS COLLECTION
        HOOK_BUILD_DIR="$WORKDIR/installed_hooks"
        rm -fr "$HOOK_BUILD_DIR" 2> /dev/null
        mkdir "$HOOK_BUILD_DIR"
        for PROFILE in $PROFILES; do
            cp -ra "./hooks/$PROFILE/"* "$HOOK_BUILD_DIR"
        done
        for HK in $(find "$HOOK_BUILD_DIR" -type l); do
            LNK=$(readlink "$HK")
            if [ ! -f "$LNK" ]; then
                ln -sf "${LNK/..\/.\//../hooks/}" "$HK"
            fi
        done
        HOOK_BUILD_FLAG=1
    fi

    step "Executing $DISTRIB hooks..."
    for hook in "$HOOK_BUILD_DIR/$1/"*.sh ; do
        step2 "HOOK $hook"
        $hook
    done
}

function reset_rootfs() {
    step "Clear old rootfs"
    sudo rm -fr "$R" 2> /dev/null
    sudo mkdir "$R" 2> /dev/null
}

function base_install() {
    # TODO configuration step
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
    if [ -n "$DISTRO_PACKAGE_LIST" ]; then
        step2 "Distribution packages"
        install_pkg $DISTRO_PACKAGE_LIST
    fi
    step2 "Extra packages"
    if ls extra_packages/*pkg.tar* >/dev/null 2>&1 ; then
        raw_install_pkg --needed -U --noconfirm extra_packages/*pkg.tar*
    fi

    run_hooks post-install
    distro_install_hook
    if [ -n "$LIVE_SYSTEM" ]; then
        sudo cp -r extra_files/* "$R/boot/"
    fi
}

function make_squash_root() {
    step "Cleaning FS & building SQUASHFS"
    IF=../ignored.files
    pushd "$R" >/dev/null || exit -2
        sudo find boot/* > $IF
        sudo find var/cache/ -type f >> $IF
        sudo mksquashfs . "$SQ" -ef $IF -comp $COMPRESSION_TYPE -no-exports -noappend -no-recovery
    popd > /dev/null
    rm ignored.files
}

function grub_install() {
    F="$1"
    D="$2"
    BIOS_MOD="normal search search_fs_uuid search_label search_fs_file part_gpt part_msdos fat usb"
    sudo grub-install --target x86_64-efi --efi-directory "$F" --removable --modules "$BIOS_MOD" --bootloader-id "$DISKLABEL" --no-nvram --force-file-id
    sudo grub-install --target i386-pc --boot-directory "$F" --removable --modules "$BIOS_MOD" "$D"
}

function grub_on_img() {
    step "Installing bootloader"
    ROOT_DEV=$(losetup --show -f "$D")
    grub_install "$T/" "$ROOT_DEV"
    losetup -d "$ROOT_DEV"
}

function mount_part0() {
    OFFSET=$(($SECT_SZ * $(fdisk -lu "$D" |grep "^$D" |awk '{print $3}') ))
    LO_DEV=$(losetup -o "$OFFSET" --show -f "$D")

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

function mount_root_from_image() {
    mount_part0
    echo "Mounted in $T, ^D to leave "
    cd "$T"
        $SHELL
    cd ..
    umount_part0
}

function make_disk_image() {
    # computed disk size, in MB
    CDS=$(( $(stat -c '%s' "${SQ}") / 1000000 + $(du -s "${R}/boot" | cut -f1) / 1000  + ${DISK_MARGIN} ))

    step "Creating disk image (${CDS} MB, ${DISK_MARGIN} reserved)"

    dd if=/dev/zero "of=${D}" bs=1M count=${CDS}

    #  Make partitions
    echo -e "n\np\n1\n\n\nt\nef\na\nw" | LC_ALL=C fdisk "$D" >/dev/null 

    step2 "Creating FAT32 filesystem"
    OFFSET=$(($SECT_SZ * $(fdisk -lu "$D" |grep "^$D" |awk '{print $3}') ))
    LO_DEV=$(losetup -o "$OFFSET" --show -f "$D")
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
    m*)
        mount_root_from_image
        exit
        ;;
	shell*)
		sudo arch-chroot "$R"
        exit
		;;
    conf*)
        reconfigure
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
    flash)
		shift # pop the first argument
        drive=$1
        mkdir usb_drive_tmpmnt 2>/dev/null
        sudo mount $drive usb_drive_tmpmnt || exit 1
        step "Copying boot..."
        sudo cp -ar "$R/boot/"* usb_drive_tmpmnt/ || exit 1
        step "Copying root (can take a while)..."
        sudo cp "$SQ" usb_drive_tmpmnt/ || exit 1
        step "Installing GRUB..."
        grub_install usb_drive_tmpmnt/ "${drive:0:-1}"
        step "Syncing."
        sudo umount ./usb_drive_tmpmnt
        sudo sync
        sudo rm -fr usb_drive_tmpmnt
        sudo dosfslabel "$drive" "$DISKLABEL"
        exit
        ;;
    all*)
        reset_rootfs
        base_install
        reconfigure
        run_install_hooks
        if [ -n "$LIVE_SYSTEM" ]; then
            make_squash_root
            make_disk_image
        else
            echo "TODO: flash disk w/ grub"
        fi
        ;;
	*)
        echo "Usage: $0 <command> [options]"
        echo "Commands:"
        echo "       all: build the full system from scratch (RUN THIS FIRST)"
        echo "       run: runs QEMU emulator"
        echo "        up: re-create rootfs after a manual update (default)"
        echo "     shell: start a shell"
        echo "   install: install some package (args = pacman args)"
        echo "      conf: re-create intial ramdisk"
        echo "    squash: re-create squash rootfs"
        echo "      disk: re-create disk image from current squash & ramdisk"
        echo "     flash: install rootfs to some USB drive & make it bootable (arg = FAT partition)"
        exit 0
esac

echo "Type \" $0 install <package name> \" to install a new package"
echo "or \" $0 up \" to rebuild the disk image"

