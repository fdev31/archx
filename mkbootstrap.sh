#!/bin/bash

if [ ! -e configuration.sh ]; then
    echo "This script must be executed from its own original folder"
    exit 1
fi

source ./strapfuncs.sh

DEPS="grub arch-install-scripts sudo dosfstools squashfs-tools xz"

#if [ -n "$SECUREBOOT" ]; then
#    DEPS="$DEPS preloader-signed"
#fi

ERROR=0
pacman -Qq $DEPS > /dev/null || ERROR=1

[ $ERROR -ne 0 ] && echo "Required packages: $DEPS" 
[ $ERROR -ne 0 ] && exit 1

SECT_SZ=512
ROOT_DEV=''
HOOK_BUILD_FLAG=0

function run_hooks() {
    if [ $HOOK_BUILD_FLAG -eq 0 ]; then
        # BUILD CURRENT HOOKS COLLECTION
    HOOK_BUILD_DIR="$WORKDIR/.installed_hooks"
    rm -fr "$HOOK_BUILD_DIR" 2> /dev/null
    mkdir "$HOOK_BUILD_DIR"
    for PROFILE in $PROFILES; do
        step2 " ===> profile $PROFILE"
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

    install_extra_packages

    distro_install_hook
    sudo systemctl --root ROOT set-default ${BOOT_TARGET}.target
    run_hooks post-install
    install_pkg -Sc --noconfirm
}

function install_extra_packages() {
    step2 "Extra packages"
    if [ -z "$NO_EXTRA_PACKAGES" ] && ls extra_packages/*pkg.tar* >/dev/null 2>&1 ; then
        sudo pacman -r "$R" -U --needed --noconfirm extra_packages/*pkg.tar*
    fi
}

function make_squash_root() {
    step "Cleaning FS & building SQUASHFS"
    IF=../ignored.files
    pushd "$R" >/dev/null || exit -2
        sudo find boot/ | sed 1d > $IF
        sudo find var/cache/ | sed 1d >> $IF
        sudo find run/ | sed 1d >> $IF
        sudo find var/run/ -type f >> $IF
        sudo find var/log/ -type f >> $IF

        sudo find proc/ | sed 1d >> $IF
        sudo find sys/ | sed 1d >> $IF
        sudo find dev/ -type f >> $IF

        if [ ! -d ".$LIVE_SYSTEM" ]; then
            sudo mkdir ".$LIVE_SYSTEM"
        fi

        if [ -n "$NOCOMPRESS" ]; then
            sudo mksquashfs . "$SQ" -ef $IF  -noI -noD -noF -noX -no-exports -noappend -no-recovery
        else
            if [ "$COMPRESSION_TYPE" = "xz" ]; then
                sudo mksquashfs . "$SQ" -ef $IF -comp xz   -no-exports -noappend -no-recovery -b 1M  -Xdict-size '100%'
            else # gz == gzip
                sudo mksquashfs . "$SQ" -ef $IF -comp gzip -no-exports -noappend -no-recovery -b 1M
            fi
        fi  
    popd > /dev/null
    sudo rm ignored.files
}

function grub_install() {
    F="$1"
    D="$2"
    BIOS_MOD="normal search chain search_fs_uuid search_label search_fs_file part_gpt part_msdos fat usb ntfs ntfscomp"
    sudo grub-install --target x86_64-efi --efi-directory "$F" --removable --modules "$BIOS_MOD linux linux16 video" --bootloader-id "$DISKLABEL" --no-nvram --force-file-id
    sudo cp -r /usr/lib/grub/x86_64-efi "$F/grub/"
    sudo grub-install --target i386-pc --boot-directory "$F" --removable --modules "$BIOS_MOD" "$D"
    if [ -n "$SECUREBOOT" ]; then
        sudo cp secureboot/{PreLoader,HashTool}.efi "$F/EFI/BOOT/"
        sudo mv "$F/EFI//BOOT/BOOTX64.EFI"  "$F/EFI/BOOT/loader.efi" # loader = grub
        sudo mv "$F/EFI//BOOT/PreLoader.efi"  "$F/EFI/BOOT/BOOTX64.EFI" # default loader = preloader
    fi

}

function grub_on_img() {
    step "Installing bootloader"
    ROOT_DEV=$(sudo losetup -P --show -f "$D")
    grub_install "$T/" "$ROOT_DEV"
    sudo losetup -d "$ROOT_DEV"
}

function mount_part0() {
    OFFSET=$(($SECT_SZ * $(get_part_offset "$D" boot) ))
    LO_DEV=$(sudo losetup -o "$OFFSET" --show -f "$D")

    # Make final disk with boot + root
    T=tmpmnt
	sudo rm -fr "$T" 2> /dev/null
    sudo mkdir "$T"
    sudo mount "$LO_DEV" "$T"
}

function umount_part0() {
    sudo umount "./$T"
    sudo rmdir "$T"
    sudo sudo losetup -d "$LO_DEV"
}

function mount_root_from_image() {
    mount_part0
    echo "Mounted in $T, ^D to leave "
    cd "$T"
        $SHELL
    cd ..
    umount_part0
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
    # copy extra files to /boot
    if [ -n "$LIVE_SYSTEM" ]; then
        sudo cp -r extra_files/* "$R/boot/" 2>/dev/null || echo "No extra files to install"
    fi
#    BOOT_SZ=$(du -BM -s "$R/boot") # compute size
#    BOOT_SZ=${BOOT_SZ%%M*}


    rsize=$(( $(filesize $ROOTNAME) / 1000 / 1000 ))
    rsize=$(( $rsize + $DISK_MARGIN + $BOOT_MARGIN ))

    sudo dd if=/dev/zero of="$D" bs=1M count=$rsize

        step2 "Building persistent filesystem"
        MPT="$WORKDIR/.storage_mnt_pt"
        mkdir "$MPT"
        mkdir "$MPT/ROOT"
        mkdir "$MPT/WORK"
        sudo cp -ra "$R/home" "$MPT/ROOT" # pre-populate HOME // default settings
        
        pushd "$MPT"
            sudo tar cf - . | ${COMPRESSION_TYPE} -9 > ../rootfs.default
            sudo mv ../rootfs.default $R/boot/
        popd > /dev/null
        sudo rm -fr "$MPT"

    sudo DISKLABEL="ARCHINST" ./resources/mkparts.sh "$D" $BOOT_MARGIN "$SQ"
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
    m*)
        mount_root_from_image
        ;;
	shell*)
        shift
		sudo arch-chroot "$R" $*
		;;
	ins*)
		shift # pop the first argument
        install_pkg "$*"
		;;
    pkg)
        run_install_hooks
        ;;
    ex*)
        install_extra_packages
        ;;
    hook*)
        source "$1"
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
    reb*)
        reconfigure
        make_squash_root
        make_disk_image
        ;;
    up*)
        run_install_hooks
        make_squash_root
        make_disk_image
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
#        echo "     flash: install rootfs to some USB drive & make it bootable (arg = FAT partition)"
        exit 0
esac
echo "Done"

