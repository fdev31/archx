#MOVABLE ROOT PATCH

lbl="DISKLABEL"
img="ROOTIMAGE"

# overlay fs for RAM session
O_WORK_DIR=/run/workoverlay
O_OV_DIR=/run/lostoverlay

BOOTROOT=/movroot # original root, includes root.img squashfs image
LOOPROOT=/real_root # squashfs mounted here

mkdir $BOOTROOT
mkdir $LOOPROOT
mkdir $O_WORK_DIR
mkdir $O_OV_DIR

"$mount_handler" $BOOTROOT # Mount boot device

echo "Mounting SquashFS..."

if [ -e $BOOTROOT/${img}-new ]; then
    echo "Found new ROOTfs !";
    # TODO: snapshots handling
    read
fi

mount -o loop -t squashfs $BOOTROOT/$img $LOOPROOT
mount overlay -t overlay -o rw,lowerdir=$LOOPROOT,upperdir=$O_OV_DIR,workdir=$O_WORK_DIR /new_root

# make orinal root accessible as /boot
mount --bind /movroot/ /new_root/boot

# allow future script to make snapshots
mkdir /new_root/.ghost
mount --bind $O_OV_DIR /new_root/.ghost


#-MOVABLE ROOT PATCH
