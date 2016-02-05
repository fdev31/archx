#MOVABLE ROOT PATCH

export SQUASH_IMAGE="ROOTIMAGE"
export BTRFS_IMAGE="rootfs.btr"
export SESSION_FILE="session.txz"

# overlay fs for RAM session
export OVERLAY_UPPER="/run/overlay"
export OVERLAY_WORKDIR="/run/overlay_work"

export FS_BOOT="/fat_root" # original root, includes squashfs image
export FS_ROOT_RO="/squash_root" # squashfs mounted here
export FS_ROOT_RW="/btr_root" # btrfs mounted here

BTRFS_OPTS="ssd,compress,discard,relatime"

mkdir "$FS_BOOT"
mkdir "$FS_ROOT_RO"
mkdir "$FS_ROOT_RW"
mkdir "$OVERLAY_UPPER"
mkdir "$OVERLAY_WORKDIR"

RR="$FS_ROOT_RO/bin"

"$mount_handler" $FS_BOOT # Mount boot device

# Simple init: remount boot device rw & mount Squashfs from it
# Remount RW (we need it to write on BTRFS)
echo "Loading filesystems..."
mount "$FS_BOOT" -o remount,rw

# Mount squash (base RO filesystem)
mount -o loop -t squashfs "$FS_BOOT/$SQUASH_IMAGE" "$FS_ROOT_RO"
echo "- squash image loaded"

# Loading key map
if [ -e "/$FS_ROOT_RO/usr/share/kbd/keymaps/initrd.map" ]; then
    loadkmap < "/$FS_ROOT_RO/usr/share/kbd/keymaps/initrd.map"
    echo "- keymap"
fi

##### Choices:
##  - shell:  run an interactive shell after mounts
##  - nobtr:  100% volatile system (in RAM)
##  - homeonly:  /home is non-volatile
##    else       / is non-volatile

# Mount huge RAMFS overlay

mount overlay -t overlay -o "lowerdir=$FS_ROOT_RO,upperdir=$OVERLAY_UPPER,workdir=$OVERLAY_WORKDIR" /new_root
mkdir /new_root/.ghost # ram accessible as ghost
mount --bind "$OVERLAY_UPPER" /new_root/.ghost

mount_overlays() {
    for FOLD in "$@"; do
        echo " [M] $FOLD"
        FLAT_NAME=$(echo $FOLD | sed 's#/#_#g')
        FLAT_NAME=${FLAT_NAME:1}
        if [ ! -d "$PFX$FLAT_NAME" ]; then
            mkdir "$PFX$FLAT_NAME"
            mkdir "$WPFX$FLAT_NAME"
        fi
        M_OPTS="lowerdir=$FS_ROOT_RO$FOLD,upperdir=$PFX$FLAT_NAME,workdir=$WPFX${FLAT_NAME}"
        mount /dev/loop1 -t overlay -o "$M_OPTS" /new_root$FOLD
    done
}

if [ ! -e "$FS_BOOT/$BTRFS_IMAGE" ] || [ -n "$nobtr" ]; then
    # RAMFS + SQUASH on /
    echo "- mode: VOLATILE"
    if [ -n "$nobtr" ] && [ -e "$FS_BOOT/$SESSION_FILE" ]; then # check session file/unpack
        echo "- recovering saved session"
        "$RR/xzcat" "$FS_BOOT/$SESSION_FILE" | "$RR/tar" xvf - -C /new_root
    fi
else
    # WE HAVE PERSISTENCE HERE
    echo "- mode: STORED"
    mount "$FS_BOOT/$BTRFS_IMAGE" "$FS_ROOT_RW" -o $BTRFS_OPTS
    mkdir /new_root/.ghost_rw # create ghost folder & mount Stored there
    mount --move "$FS_ROOT_RW" /new_root/.ghost_rw
    PFX="/new_root/.ghost_rw/ROOT/" # new prefix
    WPFX="/new_root/.ghost_rw/WORK/" # new prefix


    # Mount filesytems
    echo " [M] /home"
    mount --bind  "$PFX/home" /new_root/home
    if [ -n "$homeonly" ]; then
        echo "- persistence: HOME"
    else
        mount_overlays "/var/lib" "/var/db" "/usr/lib" "/usr/share" "/opt" "/etc"
    fi
fi

# Bind /boot
echo "- moving mountpoints to new root"
mount --move "$FS_BOOT" /new_root/boot

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
export OVERLAY_WORKDIR=
export OVERLAY_UPPER=
export FS_BOOT=
export FS_ROOT_RO=

#MOVABLE ROOT PATCH END
