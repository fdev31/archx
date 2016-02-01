#MOVABLE ROOT PATCH

FS_IMAGE="ROOTIMAGE"

SESSION_FILE="session.txz"
HOME_FILE="home.btrfs"
ETC_FILE="etc.btrfs"

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

if [ -e $BOOTROOT/${FS_IMAGE}-new ]; then
    echo "Found new ROOT FS !";
    # TODO: snapshots handling
    read
fi

mount -o loop -t squashfs $BOOTROOT/$FS_IMAGE $LOOPROOT
mount overlay -t overlay -o rw,lowerdir=$LOOPROOT,upperdir=$O_OV_DIR,workdir=$O_WORK_DIR /new_root

# Handle sessions / snapshots

if [ -e "/movroot/$SESSION_FILE" ]; then
    RR=/new_root/bin
    $RR/xzcat "/movroot/$SESSION_FILE" | $RR/tar xvf -  -C /new_root
fi

BTRFS_OPTS="ssd,compress,discard,relatime"

# make orinal root accessible as /boot + hide upper dir somewhere
mount --bind /movroot/ /new_root/boot
mkdir /new_root/.ghost
mount --bind $O_OV_DIR /new_root/.ghost

#MOVABLE ROOT PATCH END
