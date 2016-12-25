# Name for this Linux distribution
DISKLABEL="ARCHX"
# Package set to install
DISTRIB="default"
# Your login id
USERNAME="user"
USERID="1000"
USERGID="100"
# do you prefer qt or gtk ?
PREFERRED_TOOLKIT="gtk" # or "qt" , keep LOWERCASE !
# root & user password:
PASSWORD="sexy"

# Advanced users only:

PACMAN_BIN=yaourt # alternative pacman frontend, else set "sudo pacman"
WORKDIR="$PWD" # default workdir = script dir
COMPRESSION_TYPE="xz" # xz or gzip (faster, uses less memory, but bigger files)
DISK_MARGIN=30 # extra space for persistence, also HOME size, used for loopback or disk images
BOOT_MARGIN=50 # extra space for /boot (first partition)
DEFAULT_GROUPS="lp,disk,network,audio,storage,input,power,users,wheel,adm,tty,log,sys,daemon,root"
NO_EXTRA_PACKAGES= # set to 1 to disable extra packages
SHARED_CACHE=1 # comment to not use host package cache
SECUREBOOT=1 # enables secureboot compatibility
BOOT_TARGET="graphical"

USE_LIVE_SYSTEM=1 # 1= live system, empty= standard archlinux install
# if USE_LIVE_SYSTEM=1:
LIVE_SYSTEM="/storage" # enables stored extra partition in that mountpoint
USE_RWDISK=1 # "loop" (loopback in first part), "" (no) or anything else (yes)

# if USE_RWDISK=loop:
ROOT_TYPE="ext4" # btrfs or ext4

# Customize names
ROOTNAME="rootfs.s"
R="$WORKDIR/ROOT"
D="$WORKDIR/$DISKLABEL.img"
SQ="$WORKDIR/$ROOTNAME"

PKG_BASE="base flashdisk installer locales net-chat net-utils system"
PKG_XORG="xorg www"
PKG_EDIT="editors dev-base"
PKG_GFX="gfx-base gfx-more photo-base"
PKG_UI="lookandfeel"
PKG_EMU="emulation"
PKG_MED="medical"
PKG_DOC="office-base office-more"
PKG_SRV="servers"
PKG_SND="snd-base snd-more snd-adv"

# also: proprietary
# envs: awesome, budgie, cinnamon, deepin, enlightenment, gnome, kde, lxde, mate, pantheon, xfce, zorin
