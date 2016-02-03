DISKLABEL="ARCHX"

DISTRIB="basic"

USERNAME="guest"

PREFERRED_TOOLKIT="" # or "qt" , keep LOWERCASE !

PASSWORD="plop"

PACMAN_BIN=yaourt

WORKDIR="$PWD"

# Advanced users only:

SHARED_CACHE=1 # comment to not use host package cache
COMPRESSION_TYPE="xz" # xz or gzip (faster, uses less memory, but bigger files)
DISK_MARGIN=200 # in megabytes
DEFAULT_GROUPS="lp,disk,network,audio,storage,input,power,users,wheel"
ADMIN_GROUPS="lp,disk,network,audio,storage,input,power,users,wheel,adm,tty,log,sys,daemon,root"

LIVE_SYSTEM=1 # Runs in RAMFS
USE_LOOP_RWDISK="btrfs.img" # Have persistent folders in a loopback btrfs
#USE_LOOP_RWDISK= # uncomment to disable persistence
PERSISTENT_FOLDERS="home etc" # !! NO TAIL or LEADING SLASH !!!

# Customize names
ROOTNAME="rootfs.s"
R="$WORKDIR/ROOT"
D="$WORKDIR/testimage.raw"
SQ="$WORKDIR/$ROOTNAME"
