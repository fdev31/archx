#!/bin/sh
FSTYPE="${TYPE=ext4}"
FORCE="${FORCE=yes}"
BOOTPART=$(mount 2>/dev/null | grep " $R/boot ")
BOOTPART=${BOOTPART%% *}
BOOTDRIVE=${BOOTPART%?}

DISKLABEL=$(blkid $BOOTPART -s LABEL -p)
DISKLABEL=${DISKLABEL#*\"}
DISKLABEL=${DISKLABEL%\"*}

zenity --question --text "Proceed installing on $DISKLABEL (${BOOTDRIVE}2) ?"

if [ "$?" -ne "0" ]; then
    echo "Canceled"
	exit 255
fi

case $FSTYPE in
btr*)
	M_OPTS="compress=lzo,ssd,discard"
	if [ "$FORCE" = "no" ]; then
		MK_OPTS="-M"
	else
		MK_OPTS="-M -f"
	fi
	break
	;;
*)
	M_OPTS="discard"
	if [ "$FORCE" = "no" ]; then
		MK_OPTS=""
	else
		MK_OPTS="-F"
	fi
	;;
esac

PARTCOUNT=$(ls $BOOTDRIVE* | wc -l)
SUBSCRIPT=/tmp/mountandcopy.sh
T=/tmp/plop_storage_creation
cat > $SUBSCRIPT <<EOF
oops() {
	echo "Error ! $*"
	exit -1
}
partx "$BOOTDRIVE"
if [ "$PARTCOUNT" -ne "3" ]; then
	echo "Invalid partition layout"
	exit 200
fi
# extend partition
echo "d\n2\nn\np\n\n\n\n\nw" | LC_ALL=C fdisk ${BOOTDRIVE} > /dev/null 2>&1

# make fs
mkfs.${FSTYPE} ${MK_OPTS} -L "$DISKLABEL-RW" "${BOOTDRIVE}2" || oops "mkfs failed"

# copy files
mkdir "$T"
mount -o ${M_OPTS} "${BOOTDRIVE}2" "$T" || oops "mount failed"
tar xf "$R/boot/rootfs.default" -C "$T" || oops "unpack failed"
umount "$T"
rmdir "$T"
sync
sync
sync
sync
partx "$BOOTDRIVE"
EOF
pkexec /bin/sh $SUBSCRIPT
rm $SUBSCRIPT
echo "$FSTYPE FS BUILT"
zenity --warning --text "Now reboot to apply changes"
