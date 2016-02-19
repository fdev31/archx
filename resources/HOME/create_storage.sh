#!/bin/sh
FSTYPE="${TYPE=ext4}"
FORCE="${FORCE=yes}"
BOOTPART=$(mount 2>/dev/null | grep " $R/boot ")
BOOTPART=${BOOTPART%% *}
BOOTDRIVE=${BOOTPART%?}

sudo partx "$BOOTDRIVE"

DISKLABEL=$(blkid $BOOTPART -s LABEL -p)
DISKLABEL=${DISKLABEL#*\"}
DISKLABEL=${DISKLABEL%\"*}

zenity --question --text "Proceed installing on $DISKLABEL (${BOOTDRIVE}2) ?"

if [ "$?" -ne "0" ]; then
	exit 1
fi

echo $BOOTDRIVE

oops() {
	echo "Error ! $*"
	exit -1
}


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
if [ "$PARTCOUNT" -eq "3" ]; then # default 2 partition mode
	# extend partition
	echo "d\n2\nn\np\n\n\n\n\nw" | sudo LC_ALL=C fdisk ${BOOTDRIVE} > /dev/null 2>&1
fi

sudo mkfs.${FSTYPE} ${MK_OPTS} -L "$DISKLABEL-RW" "${BOOTDRIVE}2" || oops "mkfs failed"

T=/tmp/plop_storage_creation
mkdir "$T"
sudo mount -o ${M_OPTS} "${BOOTDRIVE}2" "$T" || oops "mount failed"
sudo tar xf "$R/boot/rootfs.default" -C "$T" || oops "unpack failed"
sudo umount "$T"
rmdir "$T"
sudo sync
sync
sync
sync
sudo partx "$BOOTDRIVE"
echo "$FSTYPE FS BUILT"
echo "---------------------------"
echo " Reboot to enjoy changes !"
echo "---------------------------"
zenity --warning --text "Now reboot to apply changes"
