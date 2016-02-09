#!/bin/sh

RPFX="/mnt/persist"

mount_persist() {
    if [ -e "/run/overlay/.reset_state" ]; then
        xzcat -d /boot/rootfs.btr.xz > /boot/rootfs.btr
        reboot
    fi
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
