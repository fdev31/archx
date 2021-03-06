#!/usr/bin/env sh
# Generates a disk image
# - generate the empty disk image file
# - computes sizes and then call the standard installer

if [ ! -e configuration.sh ]; then
    echo "This script must be executed from its own original folder"
    exit 1
fi

source ./strapfuncs.sh
# vars:
# ROOT SQ LIVE_SYSTEM ROOTNAME (squashfs ?) WORKDIR DISK_TOTAL_SIZE BOOT_MARGIN DISK_MARGIN COMPRESSION_TYPE

# computed disk size, in MB
# copy extra files to /boot
if [ -n "$LIVE_SYSTEM" ]; then
    sudo cp -ar extra_files/* "$R/boot/" 2>/dev/null || echo "No extra files to install"
fi

if [ $DISK_TOTAL_SIZE ] ; then
    rsize=${DISK_TOTAL_SIZE}000
else
    sqsize=$(( $(filesize $ROOTNAME) / 1000 / 1000 ))
    rsize=$(( $sqsize + $DISK_MARGIN + $BOOT_MARGIN ))
fi
echo "Creating disk image of ${rsize}MB"
dd if=/dev/zero of="$D" bs=1MB count=$rsize

step2 "Building persistent filesystem"
MPT="$WORKDIR/.storage_mnt_pt"
if [ -e "$MPT" ]; then
    $SUDO rm -fr "$MPT"
fi
mkdir "$MPT"
mkdir -p "$MPT/ROOT/home/$USERNAME"
mkdir "$MPT/WORK"
sudo cp -ra "resources/HOME/" "$MPT/ROOT/home/$USERNAME" # pre-populate HOME // default settings

pushd "$MPT"
sudo tar cf - . | xz -9 > ../rootfs.default
sudo mv ../rootfs.default $R/boot/
popd > /dev/null
sudo rm -fr "$MPT"

sudo ROOT="$R" ROOT_TYPE="$ROOT_TYPE" DISKLABEL="ARCHINST" ./resources/installer-standard.sh "$D" $BOOT_MARGIN "$SQ"
sudo pacman -r "$R" -Qtt | sort > $DISTRIB-pkglist.txt
