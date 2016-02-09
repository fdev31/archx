#MOVABLE ROOT PATCH

export SQUASH_IMAGE="ROOTIMAGE"
export BTRFS_IMAGE="rootfs.btr"
export SESSION_FILE="session.txz"

# overlay fs for RAM session
export F_TMPFS_ROOT="/run/overlay"
export F_TMPFS_WORK_ROOT="/run/overlay_work"

export F_BOOT_ROOT="/fat_root" # original root, includes squashfs image
export F_SQUASH_ROOT="/squash_root" # squashfs mounted here


mkdir "$F_BOOT_ROOT"
mkdir "$F_SQUASH_ROOT"
mkdir "$F_TMPFS_ROOT"
mkdir "$F_TMPFS_WORK_ROOT"

"$mount_handler" $F_BOOT_ROOT # Mount boot device

# Simple init: remount boot device rw & mount Squashfs from it
# Remount RW (we need it to write on BTRFS)

oops() {
    echo "Error occured, continuing in 1s..."
    sleep 1
}

remount_boot_root() {
    echo "Loading filesystems..."
    mount --move "$F_BOOT_ROOT" /new_root/boot || oops
    mount /new_root/boot -o remount,rw || oops
}

mount_squash() {
    # Mount squash (base RO filesystem)
    mount -o loop -t squashfs "$F_BOOT_ROOT/$SQUASH_IMAGE" /new_root || oops
    echo "- squash image loaded"
}

# Loading key map
load_kmap() {
    if [ -e "/new_root/usr/share/kbd/keymaps/initrd.map" ]; then
        loadkmap < "/new_root/usr/share/kbd/keymaps/initrd.map" || oops
        echo "- keymap"
    fi
}

##### Choices:
##  - shell:  run an interactive shell after mounts
##  - nobtr:  100% volatile system (in RAM)
##  - homeonly:  /home is non-volatile
##    else       / is non-volatile

# Mount huge RAMFS overlay


create_mega_overlay() {
    for FOLD in etc home opt srv usr mnt var/db var/lib; do
        mkdir -p "$F_TMPFS_ROOT/$FOLD" "$F_TMPFS_WORK_ROOT/$FOLD"
        mount tmpfs-ov -t overlay -o "lowerdir=/new_root/$FOLD,upperdir=$F_TMPFS_ROOT/$FOLD,workdir=$F_TMPFS_WORK_ROOT/$FOLD" "/new_root/$FOLD" || oops
    done
#    mkdir /new_root/.ghost # ram accessible as ghost
#    mount --bind "$F_TMPFS_ROOT" /new_root/.ghost
}

run_newroot() {
    LD_LIBRARY_PATH="/new_root/lib" /new_root/bin/$*
}

mount_squash
load_kmap
remount_boot_root
create_mega_overlay

mount_overlays() {
    for FOLD in "$@"; do
        echo " [M] $FOLD"
        FLAT_NAME=$(echo $FOLD | sed 's#/#_#g')
        FLAT_NAME=${FLAT_NAME:1}
        if [ ! -d "$PFX$FLAT_NAME" ]; then
            mkdir "$PFX$FLAT_NAME"
            mkdir "$WPFX$FLAT_NAME"
        fi
        M_OPTS="lowerdir=/new_root$FOLD,upperdir=$PFX$FLAT_NAME,workdir=$WPFX$FLAT_NAME"
        umount /new_root$FOLD
        mount /dev/loop1 -t overlay -o "$M_OPTS" /new_root$FOLD || oops
    done
}

if [ -e "/new_root/boot/$BTRFS_IMAGE" ] && [ -z "$nobtr" ]; then
    # WE HAVE PERSISTENCE HERE
    echo "- mode: STORED"
    losetup /dev/loop1 "/new_root/boot/$BTRFS_IMAGE"
    if run_newroot fsck.ext4 /dev/loop1 -y ; then
        BTRFS_OPTS="discard,relatime"
        echo "FS: EXT4"
    else
        BTRFS_OPTS="ssd,compress,discard,relatime"
        run_newroot btrfs check -p --repair --check-data-csum /dev/loop1 || oops
        echo "FS: BTR"
    fi

    mkdir /new_root/mnt/storage # create ghost folder & mount Stored there
    mount /dev/loop1 /new_root/mnt/storage -o $BTRFS_OPTS || oops
    PFX="/new_root/mnt/storage/ROOT/" # new prefix
    WPFX="/new_root/mnt/storage/WORK/" # new prefix

    # Mount filesytems
    echo " [M] /home"
    umount /new_root/home
    mount --bind "$PFX/home" /new_root/home || oops
    if [ -n "$homeonly" ]; then
        true
    else
        mount_overlays /etc /var/db /usr /srv /opt
#        mount_overlays ${persist//:/ }
    fi
else
    # RAMFS + SQUASH on /
    echo "- mode: VOLATILE"
    RR="$F_SQUASH_ROOT/bin"
    if [ -n "$nobtr" ] && [ -e "$F_BOOT_ROOT/$SESSION_FILE" ]; then # check session file/unpack
        echo "- recovering saved session"
        "$RR/xzcat" "$F_BOOT_ROOT/$SESSION_FILE" | "$RR/tar" xvf - -C /new_root
    fi
fi

unset nobtr
unset homeonly

if [ -n "$shell" ] ; then
    sh -i
    unset shell
fi

echo 'Starting, yey !'

export SQUASH_IMAGE=
export BTRFS_IMAGE=
export SESSION_FILE=
export F_TMPFS_WORK_ROOT=
export F_TMPFS_ROOT=
export F_BOOT_ROOT=
export F_SQUASH_ROOT=

#MOVABLE ROOT PATCH END
