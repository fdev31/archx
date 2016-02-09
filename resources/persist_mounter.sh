#!/bin/sh

RPFX="/mnt/persist"

mount_persist() {
    return # handled by initrd
}
myumount() {
    P=$1
     if ps axuw |grep $P |grep -v grep; then
        umount "$RFPX" || return 2
     fi
}
unmount_persist() {

    umount /home || exit -1
    for DIR in /etc /var/db /usr /srv /opt /var/lib; do
        myumount "$DIR" || exit -1
    done

    umount "$RFPX" || exit -1
    sync
    mount -o remount,ro /boot || exit -1
    echo "DATA is SAFE"
}

# Run
"$1"_persist
