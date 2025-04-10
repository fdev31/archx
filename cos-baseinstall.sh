#!/usr/bin/env sh
# - populates the root folder with a minimal archlinux system
# - sets the conf & resources inside the root folder
# - RUNS pre-mkinitcpio hooks

if [ ! -e configuration.sh ]; then
    echo "This script must be executed from its own original folder"
    exit 1
fi

source ./strapfuncs.sh
source ./coslib.sh

# Required packages
sudo pacman -S arch-install-scripts squashfs-tools grub

step "Installing base packages & patch root files"

# install packages

sudo pacstrap -cP "$R" --needed base base-devel fakeroot linux initramfs linux-firmware python sudo geoip
sudo chown root.root "$R"
sudo cp my_conf.sh "$R"
sudo chmod 777 "$R/my_conf.sh"
cat distrib/$DISTRIB.sh >> "$R/my_conf.sh"

# hardlink resources
sudo ln -f strapfuncs.sh configuration.sh "$R"
find resources -type f -print0 | while IFS= read -r -d '' f; do
    d=$(dirname "$f")
    sudo ln -f "$f" "$R/$f"
done

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
