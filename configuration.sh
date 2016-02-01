DISKLABEL="ARCHX"

DISTRIB="basic"

USERNAME="guest"

PREFERRED_TOOLKIT="gtk" # or "qt" , keep LOWERCASE !

PASSWORD="plop"

PACMAN_BIN=yaourt

WORKDIR="$PWD"

# Advanced users only:

SHARED_CACHE=1 # comment to not use host package cache
COMPRESSION_TYPE="xz" # xz or gzip (faster, uses less memory, but bigger files)
DISK_MARGIN=1 # in megabytes
DEFAULT_GROUPS="lp,disk,network,audio,storage,input,power,users,wheel"
ADMIN_GROUPS="lp,disk,network,audio,storage,input,power,users,wheel,adm,tty,log,sys,daemon,root"

# Customize names
ROOTNAME="rootfs.s"
R="$WORKDIR/ROOT"
D="$WORKDIR/diskimage.raw"
SQ="$WORKDIR/$ROOTNAME"
