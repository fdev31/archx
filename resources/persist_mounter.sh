#!/bin/sh

RPFX="/mnt/persist"

mount_overlays() {
    PFX="$RPFX/ROOT/"
    WPFX="$RPFX/WORK/"
    for FOLD in "$@"; do
        echo " [M] $FOLD"
        FLAT_NAME=$(echo $FOLD | sed 's#/#_#g')
        FLAT_NAME=${FLAT_NAME:1}
        if [ ! -d "$PFX$FLAT_NAME" ]; then
            mkdir "$PFX$FLAT_NAME"
            mkdir "$WPFX$FLAT_NAME"
        fi
        M_OPTS="lowerdir=$FOLD,upperdir=$PFX$FLAT_NAME,workdir=$WPFX$FLAT_NAME"
        umount /$FOLD # in case it was tmpfs
        mount /dev/loop1 -t overlay -o "$M_OPTS" "$FOLD"
    done
}

mount_persist() {
    return
    mount -o remount,rw /boot
    mkdir -p "$RPFX"
    mount -t btrfs -o compress /boot/rootfs.btr "$RPFX" || mount /boot/rootfs.btr "$RPFX" 

    umount /home
    mount --bind "$RPFX/ROOT/home" /home

    mount_overlays /etc /var/db /usr /srv /opt /var/lib
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
