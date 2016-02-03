# Name for this Linux distribution
DISKLABEL="ARCHX"
# Package set to install
DISTRIB="basic"
# Your login id
USERNAME="guest"
# do you prefer qt or gtk ?
PREFERRED_TOOLKIT="" # or "qt" , keep LOWERCASE !
# root & user password:
PASSWORD="sexy"

# Advanced users only:

PACMAN_BIN=yaourt
WORKDIR="$PWD"
COMPRESSION_TYPE="xz" # xz or gzip (faster, uses less memory, but bigger files)
DISK_MARGIN=300 # extra space for persistence, also HOME size
DEFAULT_GROUPS="lp,disk,network,audio,storage,input,power,users,wheel"
ADMIN_GROUPS="lp,disk,network,audio,storage,input,power,users,wheel,adm,tty,log,sys,daemon,root"
NO_EXTRA_PACKAGES= # set to 1 to disable extra packages
SHARED_CACHE=1 # comment to not use host package cache

LIVE_SYSTEM=1 # Runs in RAMFS

USE_LOOP_RWDISK=1 # Have persistent folders in a loopback btrfs

# Customize names
ROOTNAME="rootfs.s"
R="$WORKDIR/ROOT"
D="$WORKDIR/testimage.raw"
SQ="$WORKDIR/$ROOTNAME"
