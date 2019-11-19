#!/bin/sh

if [ -d "ROOT" ]; then
    export RUNNING_FROM_BOOTSTRAP=1
fi

function call_fdisk() {
    DRIVE=$1
    shift
    longcmd=""
    for cmd in $*; do
        if [ "$cmd" = "-" ]; then
            longcmd="${longcmd}\n"
        else
            longcmd="${longcmd}${cmd}\n"
        fi
    done
    echo -e $longcmd | fdisk $DRIVE
}

function get_device_from_mtpoint() {
    x=$(df "$1" | tail -1)
    dev=${x%% *}
    if [ $2 ]; then
        echo $dev
    else
        if [[ "$dev" = /dev/loop* ]]; then
            echo ${dev:0:-2}
        else
            echo ${dev:0:-1}
        fi
    fi
}

function get_label_from_device() {
    lsblk -o LABEL $1 | tail -1
}
function get_uuid_from_device() {
    lsblk -o UUID $1 | tail -1
}

function install_grub() {
    DEVICE=$1
    BOOTDIR=$2
    DISKLABEL=$3
    EFIUPDATE=$4
    BOOTROOT=$5

    MOD="normal search chain search_fs_uuid search_label search_fs_file part_gpt part_msdos fat usb ntfs ntfscomp"
    if [ -n $EFIUPDATE ]; then
        EFI_OPTS="--no-nvram"
    fi

    echo "############################################################## install Boot loader"
    sudo grub-install --target x86_64-efi  --removable --compress=xz --modules "$MOD" --boot-directory "$BOOTDIR" --efi-directory "$BOOTDIR" --bootloader-id "$DISKLABEL" $EFI_OPTS 
    sudo grub-install --target i386-pc     --removable --compress=xz --modules "$MOD" --boot-directory "$BOOTDIR" $DEVICE

    for reflabel in ARCHX ARCHINST ; do
        if [ -z $DISKUUID ]; then #  just rename label
               sudo sed -i "s/$reflabel/$DISKLABEL/g" "$BOOTDIR/grub/grub.cfg"
        else # switch to uuid identification
               sudo sed -i "s/LABEL=$reflabel/UUID=$DISKUUID/g" "$BOOTDIR/grub/grub.cfg"
               sudo sed -i "s/--label $reflabel/--uuid $DISKUUID/g" "$BOOTDIR/grub/grub.cfg"
        fi
    done

    sudo sed -i "s#/vmli#$BOOTROOT/vmli#g" "$BOOTDIR/grub/grub.cfg"
    sudo sed -i "s#/init#$BOOTROOT/init#g" "$BOOTDIR/grub/grub.cfg"
    sudo sed -i "s#/grub#$BOOTROOT/grub#g" "$BOOTDIR/grub/grub.cfg"

    if [ -n "$INSTALL_SECURE_BOOT" ]; then
        sudo cp resources/secureboot/{PreLoader,HashTool}.efi "$BOOTDIR/EFI/BOOT/"
        sudo mv "$BOOTDIR/EFI/BOOT/BOOTX64.EFI"    "$BOOTDIR/EFI/BOOT/loader.efi" # loader = grub
        sudo mv "$BOOTDIR/EFI/BOOT/PreLoader.efi"  "$BOOTDIR/EFI/BOOT/BOOTX64.EFI" # default loader = preloader
    fi
}
