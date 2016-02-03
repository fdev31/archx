#MOVABLE ROOT PATCH
# opt kernel params:
# nobtr: 100% volatile system
# homeonly: /home persists, not /
# reset
# shell: start a shell before startup
export FS_IMAGE="ROOTIMAGE"
export HOME_IMAGE="homefs.btr"
export ROOT_IMAGE="rootfs.btr"

export SESSION_FILE="session.txz"
export BTRFS_IMG="btrfs.img"

# overlay fs for RAM session
export O_OV_DIR=/run/lostoverlay
export O_WORK_DIR=/run/workoverlay


export BOOTROOT=/movroot # original root, includes squashfs image
export LOOPROOT=/real_root # squashfs mounted here

mkdir $BOOTROOT
mkdir $LOOPROOT

RR="$LOOPROOT/bin"

"$mount_handler" $BOOTROOT # Mount boot device

# Remount RW (we need it to write on BTRFS)
echo "Loading filesystems..."
mount "$BOOTROOT" -o remount,rw
BTRFS_OPTS="ssd,compress,discard,relatime"

# Mount squash (base RO filesystem)
mount -o loop -t squashfs $BOOTROOT/$FS_IMAGE $LOOPROOT

loadkmap < "/$LOOPROOT/usr/share/kbd/keymaps/initrd.map"

##### Choice: SQUASH + BTR FS (persist) or SQUASH + TMPFS (volatile)

# if BTR rootfs, mount it (instead of using initrd's tmpfs)
if [ -z "$nobtr" ] && [ -z "$homeonly" ] && [ -e "$BOOTROOT/$ROOT_IMAGE" ]; then
    echo "- persistent root"
    mkdir "$O_OV_DIR"
    mount "$BOOTROOT/$ROOT_IMAGE" "$O_OV_DIR" -o $BTRFS_OPTS

    export O_WORK_DIR="$O_OV_DIR/WORK"
    export O_OV_DIR="$O_OV_DIR/ROOT"
fi

# root mounted, create workdir
mkdir -p $O_WORK_DIR
mkdir -p $O_OV_DIR

mount overlay -t overlay -o lowerdir=$LOOPROOT,upperdir=$O_OV_DIR,workdir=$O_WORK_DIR /new_root

# if BTR HOME FS, mount it (instead of using default overlay)
if [ -z "$nobtr" ] && [ -e "$BOOTROOT/$HOME_IMAGE" ]; then
    echo "- persistent home"
    mount "$BOOTROOT/$HOME_IMAGE" /new_root/home -o $BTRFS_OPTS
fi

# Handle sessions / snapshots for TMPFS systems
if [ ! -e "$BOOTROOT/$ROOT_IMAGE" ] && [ -e "$BOOTROOT/$SESSION_FILE" ]; then
    echo "- recovering saved session"
    $RR/xzcat "$BOOTROOT/$SESSION_FILE" | $RR/tar xvf -  -C /new_root
fi

# make original root accessible as /boot + hide upper dir somewhere
mount --move $BOOTROOT/ /new_root/boot -o rw
mkdir /new_root/.ghost 2>/dev/null
mount --move $O_OV_DIR /new_root/.ghost

unset nobtr

if [ -n "$shell" ] ; then
    loadkmap < "/$LOOPROOT/usr/share/kbd/keymaps/initrd.map"
    sh -i
    unset shell
fi

echo 'Starting, yey !'

export FS_IMAGE=
export HOME_IMAGE=
export ROOT_IMAGE=
export SESSION_FILE=
export BTRFS_IMG=
export O_WORK_DIR=
export O_OV_DIR=
export BOOTROOT=
export LOOPROOT=

#MOVABLE ROOT PATCH END
