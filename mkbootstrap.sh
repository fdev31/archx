#!/bin/bash

if [ ! -e configuration.sh ]; then
    echo "This script must be executed from its own original folder"
    exit 1
fi

source ./strapfuncs.sh

DEPS="grub arch-install-scripts sudo dosfstools squashfs-tools xz"

if [ -n "$SECUREBOOT" ]; then
    DEPS="$DEPS prebootloader"
fi

pacman -Qq $DEPS > /dev/null || exit "Required packages: $DEPS"


SECT_SZ=512
LO_DEV=''
ROOT_DEV=''
HOOK_BUILD_FLAG=0

function run_hooks() {
    if [ $HOOK_BUILD_FLAG -eq 0 ]; then
        # BUILD CURRENT HOOKS COLLECTION
        HOOK_BUILD_DIR="$WORKDIR/.installed_hooks"
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
        source $hook
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
    if [ -z "$NO_EXTRA_PACKAGES" ] && ls extra_packages/*pkg.tar* >/dev/null 2>&1 ; then
        sudo pacman -r "$R" -U --needed --noconfirm extra_packages/*pkg.tar*
    fi

    distro_install_hook
    if [ -n "$LIVE_SYSTEM" ]; then
        sudo cp -r extra_files/* "$R/boot/"
    fi
    run_hooks post-install
}

function make_squash_root() {
    step "Cleaning FS & building SQUASHFS"
    IF=../ignored.files
    pushd "$R" >/dev/null || exit -2
        sudo find boot/* > $IF
        sudo find var/cache/ -type f >> $IF
        if [ "$COMPRESSION_TYPE" = "xz" ]; then
            sudo mksquashfs . "$SQ" -ef $IF -comp $COMPRESSION_TYPE -no-exports -noappend -no-recovery -b 1M  -Xdict-size '100%'
        else
            sudo mksquashfs . "$SQ" -ef $IF -comp $COMPRESSION_TYPE -no-exports -noappend -no-recovery -b 1M
        fi
    popd > /dev/null
    rm ignored.files
}

function grub_install() {
    F="$1"
    D="$2"
    BIOS_MOD="normal search chain search_fs_uuid search_label search_fs_file part_gpt part_msdos fat usb ntfs ntfscomp"
    sudo grub-install --target x86_64-efi --efi-directory "$F" --removable --modules "$BIOS_MOD linux linux16 video" --bootloader-id "$DISKLABEL" --no-nvram --force-file-id
    sudo cp -r /usr/lib/grub/x86_64-efi "$F/grub/"
    sudo grub-install --target i386-pc --boot-directory "$F" --removable --modules "$BIOS_MOD" "$D"
    if [ -n "$SECUREBOOT" ]; then
        sudo cp /usr/lib/prebootloader/{PreLoader,HashTool}.efi "$F/EFI/BOOT/"
        sudo mv "$F/EFI//BOOT/BOOTX64.EFI"  "$F/EFI/BOOT/loader.efi" # loader = grub
        sudo mv "$F/EFI//BOOT/PreLoader.efi"  "$F/EFI/BOOT/BOOTX64.EFI" # default loader = preloader
    fi

}

function grub_on_img() {
    step "Installing bootloader"
    ROOT_DEV=$(losetup --show -f "$D")
    grub_install "$T/" "$ROOT_DEV"
    losetup -d "$ROOT_DEV"
}

function mount_part0() {
    OFFSET=$(($SECT_SZ * $(get_part_offset "$D" boot) ))
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

function create_btrfs() {
    if [ -n "$USE_RWDISK" ]; then
        if [ -n "$1" ]; then
            RFS="$1"
        else
            step "Creating BTRFS image of ${DISK_MARGIN} MB"
            RFS="$WORKDIR/rootfs.${ROOT_TYPE}"
            dd if=/dev/zero "of=$RFS" "bs=${DISK_MARGIN}M" count=1
        fi
        step2 "Building persistent filesystem"
        MPT="$WORKDIR/.btr_mnt_pt"
        mkdir "$MPT"
        mkdir "$MPT/ROOT"
        mkdir "$MPT/WORK"
        sudo cp -ra "$R/home" "$MPT/ROOT" # pre-populate HOME // default settings
        sudo mkdir .tmpbtr
        if [ "$ROOT_TYPE" = "btr" ]; then
            echo sudo mkfs.btrfs -L "${DISKLABEL}-RW" -M -n 4096 -s 4096 "$RFS" --root "$MPT"
            sudo mkfs.btrfs -L "${DISKLABEL}-RW" -M -n 4096 -s 4096 "$RFS" --root "$MPT"
        else
            mkfs.ext4 -O ^has_journal -m 1 -L "$DISKLABEL-RW" "$RFS"
        fi
        sudo mount "${RFS}" .tmpbtr

        if [ "$ROOT_TYPE" = "btr" ]; then
            sudo btrfs filesystem resize max  .tmpbtr
        else
            sudo cp -ra "$MPT/." .tmpbtr
        fi
        sudo umount .tmpbtr
        sudo rmdir .tmpbtr
        rm -fr "$RFS".xz
        xzcat -9 < "$RFS" > "$WORKDIR/rootfs.${ROOT_TYPE}"
        sudo rm -fr "$MPT"
    fi
}

function get_part_offset() {
    _DISK="$1"
    _IS_BOOT="$2"
    if [ -z "$_IS_BOOT" ]; then
        _GREP='-v'
    fi
    fdisk -lu $_DISK | grep ^$_DISK | grep $_GREP '*' | sed 's/*/ /' | awk '{print $2}'
}

function make_disk_image() {
    # computed disk size, in MB
    if [ -n "$USE_RWDISK" ]; then
        _DM="$DISK_MARGIN"
    else
        _DM=0
    fi
    MM=50 # marginal margin: 50B

    CDS=$(( $(stat -c '%s' "${SQ}") / 1048576 + $(du -s "${R}/boot" | cut -f1) / 1024  + ${_DM} + ${MM} ))

    step "Creating ${CDS} MB disk image (Free: /home = $_DM MB, /boot = $MM MB)"

    dd if=/dev/zero "of=${D}" bs=1M count=${CDS}

    #  Make partitions
    echo -e "n\np\n1\n\n+$(( $CDS - $_DM ))M\nt\nef\na\nw" | LC_ALL=C fdisk "$D" >/dev/null 

     # create 2nd partition
    if [ -n "$USE_RWDISK" ] && [ "$USE_RWDISK" != "loop" ]; then
        echo -e "n\np\n2\n\n\nw" | LC_ALL=C fdisk "$D" >/dev/null
        _TO=$(get_part_offset "$D")
        _OFFSET=$(( $SECT_SZ * $_TO ))
        LO_DEV=$(losetup -o "$_OFFSET" --show -f "$D")
        create_btrfs "$LO_DEV"
        losetup -d "$LO_DEV"
        LIMIT_FAT_SIZE=yes
    else
        create_btrfs
    fi

    step2 "Creating FAT32 filesystem"
    OFFSET=$(( $SECT_SZ * $(get_part_offset "$D" boot) ))
    if [ -n "$LIMIT_FAT_SIZE" ]; then
        LODEV_OPTS="--sizelimit $(( $_OFFSET - $OFFSET ))"
    fi
    LO_DEV=$(losetup -o "$OFFSET" $LODEV_OPTS --show -f "$D")
    mkdosfs -F 32 -n "$DISKLABEL" "$LO_DEV"

    step "Populating filesystem"
    # Make final disk with boot + root
    T=tmpmnt
	sudo rm -fr "$T" 2> /dev/null
    sudo mkdir "$T"
    sudo mount "$LO_DEV" "$T"

    sudo cp -ar "$R/boot/"* "$T/"

    step2 "Copying base filesystem (can take a while)..."
    sudo cp "$SQ" "$T/"
    if [ "$USE_RWDISK" = "loop" ] ; then
        step2 "Copying persistent filesystem..."
        sudo cp -r "$RFS" "$T/"
        sudo cp "$RFS".xz "$T/"
    elif [ -n "$USE_RWDISK" ]; then
        # TODO !! Copy .xz file as well // TEST !!
        echo "Copy to partition"
        sudo cp "$RFS".xz "$T/"
    fi
    step2 "Syncing."
    sudo sync
    step "Grub..."
    grub_on_img
    umount_part0
    if [ -n "$USE_RWDISK" ] && [ "$USE_RWDISK" != "loop" ] ; then
        step2 "Making additional partition (TODO)"
#        step2 "Copying persistent filesystem..."
#        sudo cp -r "$RFS" "$T/"
#        sudo cp "$RFS".xz "$T/"
    fi
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
        shift
        if [ -n "$EFI" ]; then
            BIOSDRIVE="-drive file=/usr/share/ovmf/ovmf_x64.bin,format=raw,if=pflash,readonly"
        else
            BIOSDRIVE=""
        fi
        echo qemu-system-x86_64 -m 1024 -enable-kvm $BIOSDRIVE -drive file=$D,format=raw $*
        exec qemu-system-x86_64 -m 1024 -enable-kvm $BIOSDRIVE -drive file=$D,format=raw $*
        # if GRUB is broken for you, try loading linux directly:
#        qemu-system-x86_64 -m 1024 -enable-kvm -drive file=$D,format=raw -kernel $R/boot/vmlinuz-linux -initrd $R/boot/initramfs-linux.img -append root=LABEL=$DISKLABEL
        exit
        ;;
	ins*)
		shift # pop the first argument
        install_pkg "$*"
		;;
    m*)
        mount_root_from_image
        ;;
	shell*)
		sudo arch-chroot "$R"
		;;
    conf*)
        reconfigure
        ;;
    sq*):
        make_squash_root
        make_disk_image
        ;;
    d*)
        make_disk_image
        ;;
    gr*)
        mount_part0
        grub_on_img
        umount_part0
        ;;
    pkg)
        run_install_hooks
        ;;
    up*)
        run_install_hooks
        make_squash_root
        make_disk_image
        ;;
    hook)
        source "$2"
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
#        echo "      conf: re-create intial ramdisk"
#        echo "    squash: re-create squash rootfs"
#        echo "      disk: re-create disk image from current squash & ramdisk"
        echo "     flash: install rootfs to some USB drive & make it bootable (arg = FAT partition)"
        exit 0
esac
echo "Done"

