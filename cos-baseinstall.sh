#!/usr/bin/env sh
set -e

if [ ! -e configuration.sh ]; then
    echo "This script must be executed from its own original folder"
    exit 1
fi

source ./strapfuncs.sh

step "Installing base packages & patch root files"

# install packages

sudo pacstrap -cd "$R" --needed base base-devel fakeroot linux initramfs linux-firmware python sudo geoip gcc-libs-multilib gcc-multilib
sudo chown root.root "$R"
sudo cp my_conf.sh "$R"
sudo chmod 777 "$R/my_conf.sh"
cat distrib/$DISTRIB.sh >> "$R/my_conf.sh"
sudo cp -r strapfuncs.sh configuration.sh resources "$R"

step "Re-generating RAMFS and low-level config" 
HOOK_BUILD_DIR="$R/$HOOK_BUILD_FOLDER" CHROOT='' run_hooks pre-mkinitcpio
sync
sleep 2
sync
sync
sudo umount "$R/proc" || true
sudo umount "$R/dev" || true
sudo umount "$R/sys" || true
mount
step2 "make init cpio" 
sudo arch-chroot "$R" mkinitcpio -p linux
