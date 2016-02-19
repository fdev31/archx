#MOVABLE ROOT PATCH
# NO TRAILING SLASH ALLOWED !!

## vars:
R="/new_root"
SQUASH_IMAGE={{ROOTIMAGE}}
DISKLABEL={{DISKLABEL}}
STORAGE_IMAGE={{STORAGE}}

RAMFS_FOLDERS="/mnt /var/lib" # RAMFS mounts
STORED_DIRECT="/home" # no overlay on SQUASHFS, direct mount
STORABLE_FOLDERS="/etc /opt /srv /usr /var/db /var/lib/pacman" # mount with SQUASHFS overlay

F_RWPART="{{STORAGE_PATH}}"
F_BOOT_ROOT="/fat_root" # original root, includes squashfs image
F_TMPFS_ROOT="/run/overlay/ROOT" # rootdirs prefix for tmpfs overlay
F_TMPFS_WORK_ROOT="/run/overlay/WORK" # workdirs prefix for tmpfs overlay
F_PFX="$R$F_RWPART/ROOT" # new roots prefix
F_WPFX="$R$F_RWPART/WORK" # new work prefix
DEBUG=$shell

## funcs:
oops() {
    echo "Error occured, continuing in 1s..."
    sleep 1
}

fatal() {
    echo "FATAL Error occured! $*"
    echo" press ENTER to reboot"
    read
    reboot -f
}

mount_squash() {
    # Mount squash (base RO filesystem)
    E_MSG="$SQUASH_IMAGE not found in $DISKLABEL !"
    mount -o loop -t squashfs "$F_BOOT_ROOT/$SQUASH_IMAGE" "$R" || fatal "$E_MSG"
    [ -n "$DEBUG" ] && echo "- squash image loaded"
}

load_kmap() {
    if [ -e "$R/usr/share/kbd/keymaps/initrd.map" ]; then
        loadkmap < "$R/usr/share/kbd/keymaps/initrd.map" || oops
        [ -n "$DEBUG" ] && echo "- keymap"
    fi
}

run_newroot() {
    PATH="$R/bin:$PATH" LD_LIBRARY_PATH="$R/lib" $*
}

process_mountname() {
    NAME="$1"
    if [ -z "$2" ]; then
        P="$F_PFX"
        WP="$F_WPFX"
    else
        P="$F_TMPFS_ROOT"
        WP="$F_TMPFS_WORK_ROOT"
    fi
    FLAT_NAME=$(echo $1 | sed 's#/#_#g')
    FLAT_NAME=${FLAT_NAME:1}
    if [ ! -d "$P/$FLAT_NAME" ]; then
        mkdir -p "$P/$FLAT_NAME"
    fi
    if [ ! -d "$WP/$FLAT_NAME" ]; then
        mkdir -p "$WP/$FLAT_NAME"
    fi
    echo $FLAT_NAME
}

mount_as_tmpfs_overlay() {
    [ -n "$DEBUG" ] && echo "[M] $1 (volatile)"
    FOLD="$1"
    UPFOLD=$(process_mountname "$FOLD" volatile)
    M_OPTS="lowerdir=$R$FOLD,upperdir=$F_TMPFS_ROOT/$UPFOLD,workdir=$F_TMPFS_WORK_ROOT/$UPFOLD"
    mount /dev/null -t overlay -o "$M_OPTS" "$R$FOLD" || oops
}
mount_as_stored_overlay() {
    [ -n "$DEBUG" ] && echo "[M] $1 (stored overlay)"
    FOLD="$1"
    UPFOLD=$(process_mountname "$FOLD")
    M_OPTS="lowerdir=$R$FOLD,upperdir=$F_PFX/$UPFOLD,workdir=$F_WPFX/$UPFOLD"
    mount ${DEV} -t overlay -o "$M_OPTS" "$R$FOLD" || oops
}
mount_as_no_overlay() {
    [ -n "$DEBUG" ] && echo "[M] $1 (stored)"
    FOLD="$1"
    mount --bind "$F_PFX/$FOLD" "$R$FOLD" || oops
}

## main code:

mkdir "$F_BOOT_ROOT"
"$mount_handler" $F_BOOT_ROOT # Mount boot device
mount_squash # Mount SQUASH in /
load_kmap # loading kmap from it
mount --move "$F_BOOT_ROOT" "$R/boot" || oops # make original root accessible as /boot (ro)
rmdir "$F_BOOT_ROOT" # now it's moved, we can remove original mountpoint
mount -t tmpfs tmpfs "$R/run"

# default mount types
STORED=0
STD_MOUNT_TYPE="tmpfs"
DIRECT_MOUNT_TYPE="tmpfs"
DEV="/dev/disk/by-label/${DISKLABEL}-RW"

## Mount PURE VOLATILE folders
#for FOLD in $RAMFS_FOLDERS; do
#    mount_as_tmpfs_overlay "$FOLD"
#done

# check persistant
if [ -z "$nobtr" ] && [ -e "$DEV" ] ; then # We have a storage device, Yey !!
    echo "[STORED]"
    run_newroot btrfs check -p --repair --check-data-csum "$DEV" > "/tmp/btrfs_check.log" 2>&1 && FS_OPTS="ssd,compress=lzo,discard,relatime"
    run_newroot fsck.ext4 -p "$DEV" > "/tmp/ext4_check.log" 2>&1 && FS_OPTS="discard,relatime"

    mount "$DEV" "$R/$F_RWPART" -o $FS_OPTS || oops

    mv /tmp/*.log "$R/$F_RWPART"

    if  [ -n "$FS_OPTS" ] && [ "$?" -eq "0" ] ; then
        STORED=1
        STD_MOUNT_TYPE="stored"
        DIRECT_MOUNT_TYPE="no"
    fi
else
    echo "[VOLATILE]"
    mount -t tmpfs tmpfs "$R/$F_RWPART"
    run_newroot xzcat "$R/boot/rootfs.default" | run_newroot tar xf - -C "$R/$F_RWPART"
fi

for d in home var_lib_pacman etc opt srv usr var_db; do
    echo "$F_PFX/$d"
    mkdir -p "$F_PFX/$d"
    mkdir -p "$F_WPFX/$d"
done

for d in mnt var_lib; do
    echo "$R/$F_TMPFS_ROOT/$d"
    mkdir -p "$R/$F_TMPFS_ROOT/$d"
    mkdir -p "$R/$F_TMPFS_WORK_ROOT/$d"
done
# mount /usr to make systemd happy
mount -t overlay /dev/disk/by-label/${DISKLABEL}      "$R/usr"  -o "rw,relatime,lowerdir=$R/usr,upperdir=$R/storage/ROOT/usr,workdir=$R/storage/WORK/usr"

## Mount direct/standard mountpoints
#for FOLD in $STORED_DIRECT; do # VOLATILE or RW MOUNTED
#    mount_as_${DIRECT_MOUNT_TYPE}_overlay "$FOLD"
#done
#
## Mount overlaid mountpoints
#for FOLD in $STORABLE_FOLDERS; do # VOLATILE or RW OVERLAID
#    mount_as_${STD_MOUNT_TYPE}_overlay "$FOLD"
#done

[ -n "$shell" ] && run_newroot sh -i # start a shell if requested
#MOVABLE ROOT PATCH END
