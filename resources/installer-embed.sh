#!/bin/bash

if [ -e /usr/share/installer ] ; then
    . /usr/share/installer/instlib.sh
    BOOTDIR="/boot"
    RUNNING_LIVE=1
else
    . ./resources/instlib.sh
    BOOTDIR="ROOT/boot"
fi


MNT=$1

if [ -z "$MNT" ]; then
    echo "Syntax: $0 <mountpoint>"
    exit 1
fi

DEV=$(get_device_from_mtpoint "$MNT")
PART=$(get_device_from_mtpoint "$MNT" part)

if [[ "$DEV" != */* ]]; then
    echo "Invalid device !"
    exit 1
fi

echo "DEV=$PART ($DEV)"

# POPULATE

cp -ar $BOOTDIR "$MNT"

uuid=$(get_uuid_from_device "$DEV")

DISKUUID=$uuid install_grub "$DEV" "$MNT/boot" "${lbl#*=}" "" "/boot"

if [ $RUNNING_LIVE ]; then
    d=$(get_device_from_mtpoint / partitions)
    dd if=$d of="$MNT/rootfs.s"
else
    cp rootfs.s "$MNT"
fi

