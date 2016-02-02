#MOVABLE ROOT PATCH
# opt kernel params: nobtr shell

FS_IMAGE="ROOTIMAGE"

SESSION_FILE="session.txz"
BTRFS_IMG="btrfs.img"

# overlay fs for RAM session
O_WORK_DIR=/run/workoverlay
O_OV_DIR=/run/lostoverlay

BOOTROOT=/movroot # original root, includes squashfs image
LOOPROOT=/real_root # squashfs mounted here

mkdir $BOOTROOT
mkdir $LOOPROOT
mkdir $O_WORK_DIR
mkdir $O_OV_DIR

"$mount_handler" $BOOTROOT # Mount boot device

echo "Mounting SquashFS..."

mount "$BOOTROOT" -o remount,rw

#if [ -e $BOOTROOT/${FS_IMAGE}-new ]; then
#    echo "Found new ROOT FS !";
#    # TODO: snapshots handling
#    read
#fi

mount -o loop -t squashfs $BOOTROOT/$FS_IMAGE $LOOPROOT
mount overlay -t overlay -o lowerdir=$LOOPROOT,upperdir=$O_OV_DIR,workdir=$O_WORK_DIR /new_root

# Handle sessions / snapshots

if [ -e "$BOOTROOT/$SESSION_FILE" ]; then
    RR=/new_root/bin
    $RR/xzcat "$BOOTROOT/$SESSION_FILE" | $RR/tar xvf -  -C /new_root
fi

BTRFS_OPTS="ssd,compress,discard,relatime"

# make original root accessible as /boot + hide upper dir somewhere
mount --bind $BOOTROOT/ /new_root/boot -o ro
mkdir /new_root/.ghost
mount --bind $O_OV_DIR /new_root/.ghost

# Mount 
if [ -z "$nobtr" ] && [ -e "$BOOTROOT/${BTRFS_IMG}" ]; then
    mkdir /btrfs_storage
    mount "$BOOTROOT/${BTRFS_IMG}" /btrfs_storage -o compress
    for FOLD in $(cat "$BOOTROOT/.ps") ; do
        mkdir -m 755 "/new_root/$FOLD"
        mount --bind "/btrfs_storage/$FOLD" "/new_root/$FOLD"
    done
fi
unset nobtr

if [ -n "$shell" ] ; then
    sh -i
    unset shell
fi

echo 'Starting !'

#MOVABLE ROOT PATCH END
