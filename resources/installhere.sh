#!/bin/sh

. ./resources/instlib.sh

MNT=$1

if [ -z "$MNT" ]; then
    echo "Syntax: $0 <mountpoint>"
    exit 1
fi

DEV=$(get_device_from_mtpoint "$MNT")
if [[ "$DEV" != */* ]]; then
    echo "Invalid device !"
    exit 1
fi
echo "DEV=$DEV"

# POPULATE

cp -ar ROOT/boot "$MNT"
cp rootfs.s "$MNT"


lbl=$(get_label_from_device "$DEV")

install_grub "$DEV" "$MNT/boot" "${lbl#*=}" "" "/boot"

