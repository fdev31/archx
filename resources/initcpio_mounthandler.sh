#MOVABLE ROOT PATCH

export SQUASH_IMAGE={{ROOTIMAGE}}
export STORAGE_IMAGE={{STORAGE}}
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
#    mount /new_root/boot -o remount,ro || oops
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

RAMFS_FOLDERS="etc opt srv usr mnt var/db var/lib home"
PERSIST_FOLDERS="/etc /opt /srv /usr /var/db /var/lib/pacman"

create_mega_overlay() {
    for FOLD in $RAMFS_FOLDERS; do
        mkdir -p "$F_TMPFS_ROOT/$FOLD" "$F_TMPFS_WORK_ROOT/$FOLD"
        mount tmpfs-ov -t overlay -o "lowerdir=/new_root/$FOLD,upperdir=$F_TMPFS_ROOT/$FOLD,workdir=$F_TMPFS_WORK_ROOT/$FOLD" "/new_root/$FOLD" || oops
    done
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
        DEST_DIR="/new_root$FOLD"
        if grep " $DEST_DIR " /etc/mtab > /dev/null ; then
            umount "$DEST_DIR"
        fi
        mount ${DEV} -t overlay -o "$M_OPTS" "$DEST_DIR" || oops
    done
}

if [ -e "/new_root/boot/$STORAGE_IMAGE" ] || [ -e "/dev/disk/by-label/{{DISKLABEL}}-RW" ] && [ -z "$nobtr" ]; then
    echo "- mode: STORED"

    if [ -e "/dev/disk/by-label/{{DISKLABEL}}-RW" ] ; then
        DEV="/dev/disk/by-label/{{DISKLABEL}}-RW"
    else
        # WE HAVE PERSISTENCE HERE
        DEV="/dev/loop1"
        losetup $DEV "/new_root/boot/$STORAGE_IMAGE"
    fi


    if [ "$STORAGE_IMAGE" != "${STORAGE_IMAGE%.btr}" ]; then
        echo "FS: BTR"
        FS_OPTS="ssd,compress,discard,relatime"
        run_newroot btrfs check -p --repair --check-data-csum "$DEV" || oops
    else
        echo "FS: EXT4"
        run_newroot fsck.ext4 "$DEV" -y
        FS_OPTS="discard,relatime"
    fi

    mkdir /new_root/mnt/storage # create ghost folder & mount Stored there
    mount "$DEV" /new_root/mnt/storage -o $FS_OPTS || oops
    PFX="/new_root/mnt/storage/ROOT/" # new prefix
    WPFX="/new_root/mnt/storage/WORK/" # new work prefix

    # Mount filesytems
    echo " [M] /home"
    umount /new_root/home
    mount --bind "$PFX/home" /new_root/home || oops
    if [ -n "$homeonly" ]; then
        true
    else
        mount_overlays $PERSIST_FOLDERS
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

if [ -n "$recoverfs" ]; then
    touch "$F_TMPFS_ROOT/.reset_state"
fi

if [ -n "$shell" ] ; then
    LD_LIBRARY_PATH=/new_root/lib PATH="/new_root/bin:$PATH" sh -i
    unset shell
fi

echo 'Starting, yey !'

#MOVABLE ROOT PATCH END
