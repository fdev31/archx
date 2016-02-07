#MOVABLE ROOT PATCH

export SQUASH_IMAGE="ROOTIMAGE"
export BTRFS_IMAGE="rootfs.btr"
export SESSION_FILE="session.txz"

# overlay fs for RAM session
export F_TMPFS_ROOT="/run/overlay"
export F_TMPFS_WORK_ROOT="/run/overlay_work"

export F_BOOT_ROOT="/fat_root" # original root, includes squashfs image
export F_SQUASH_ROOT="/squash_root" # squashfs mounted here

BTRFS_OPTS="ssd,compress,discard,relatime"
BTRFS_OPTS="discard,relatime"

mkdir "$F_BOOT_ROOT"
mkdir "$F_SQUASH_ROOT"
mkdir "$F_TMPFS_ROOT"
mkdir "$F_TMPFS_WORK_ROOT"

"$mount_handler" $F_BOOT_ROOT # Mount boot device

# Simple init: remount boot device rw & mount Squashfs from it
# Remount RW (we need it to write on BTRFS)
echo "Loading filesystems..."
mount "$F_BOOT_ROOT" -o remount,rw

# Mount squash (base RO filesystem)
mount -o loop -t squashfs "$F_BOOT_ROOT/$SQUASH_IMAGE" "$F_SQUASH_ROOT"
echo "- squash image loaded"

# Loading key map
if [ -e "/$F_SQUASH_ROOT/usr/share/kbd/keymaps/initrd.map" ]; then
    loadkmap < "/$F_SQUASH_ROOT/usr/share/kbd/keymaps/initrd.map"
    echo "- keymap"
fi

##### Choices:
##  - shell:  run an interactive shell after mounts
##  - nobtr:  100% volatile system (in RAM)
##  - homeonly:  /home is non-volatile
##    else       / is non-volatile

# Mount huge RAMFS overlay

mount overlay -t overlay -o "lowerdir=$F_SQUASH_ROOT,upperdir=$F_TMPFS_ROOT,workdir=$F_TMPFS_WORK_ROOT" /new_root
mkdir /new_root/.ghost # ram accessible as ghost
mount --bind "$F_TMPFS_ROOT" /new_root/.ghost

mount_overlays() {
    for FOLD in "$@"; do
        echo " [M] $FOLD"
        FLAT_NAME=$(echo $FOLD | sed 's#/#_#g')
        FLAT_NAME=${FLAT_NAME:1}
        if [ ! -d "$PFX$FLAT_NAME" ]; then
            mkdir "$PFX$FLAT_NAME"
            mkdir "$WPFX$FLAT_NAME"
        fi
        M_OPTS="lowerdir=$F_SQUASH_ROOT$FOLD,upperdir=$PFX$FLAT_NAME,workdir=$WPFX${FLAT_NAME}"
        mount /dev/loop1 -t overlay -o "$M_OPTS" /new_root$FOLD
    done
}

if [ ! -e "$F_BOOT_ROOT/$BTRFS_IMAGE" ] || [ -n "$nobtr" ]; then
    # RAMFS + SQUASH on /
    echo "- mode: VOLATILE"
    RR="$F_SQUASH_ROOT/bin"
    if [ -n "$nobtr" ] && [ -e "$F_BOOT_ROOT/$SESSION_FILE" ]; then # check session file/unpack
        echo "- recovering saved session"
        "$RR/xzcat" "$F_BOOT_ROOT/$SESSION_FILE" | "$RR/tar" xvf - -C /new_root
    fi
else
    # WE HAVE PERSISTENCE HERE
    echo "- mode: STORED"
    mkdir /new_root/.ghost_rw # create ghost folder & mount Stored there
    mount "$F_BOOT_ROOT/$BTRFS_IMAGE" /new_root/.ghost_rw -o $BTRFS_OPTS
    PFX="/new_root/.ghost_rw/ROOT/" # new prefix
    WPFX="/new_root/.ghost_rw/WORK/" # new prefix

    # Mount filesytems
    echo " [M] /home"
    mount --bind "$PFX/home" /new_root/home
    if [ -n "$homeonly" ]; then
        true
    else
        mount_overlays "/etc" "/var/db" "/var/lib" "/usr" "/opt"
    fi
fi

# Bind /boot
echo "- moving boot device under /boot"
mount --move "$F_BOOT_ROOT" /new_root/boot

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
