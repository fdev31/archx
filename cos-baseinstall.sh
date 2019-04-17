#!/usr/bin/env sh
set -e

if [ ! -e configuration.sh ]; then
    echo "This script must be executed from its own original folder"
    exit 1
fi

source ./strapfuncs.sh
# vars:
# R DISTRIB HOOK_BUILD_FOLDER

function reset_rootfs() {
    step "Clear old rootfs"
    if [ -e "$R" ]; then
        sudo mv "$R" "$R-moved"
        sudo rm -fr "$R-moved" &
    fi
    sudo mkdir "$R"
}

#function base_install() {
    # TODO configuration step
    step "Installing base packages & patch root files"
    # install packages
    sudo pacstrap -cd "$R" base python sudo geoip gcc-libs-multilib gcc-multilib base-devel yajl git expac perl # base-devel & next are needed to build cower, needed by pacaur
    sudo chown root.root "$R"
    sudo cp -r strapfuncs.sh configuration.sh resources/onelinelog.py resources my_conf.sh distrib/$DISTRIB.sh "$R"
#}

#function reconfigure() {
    HOOK_BUILD_DIR="$R/$HOOK_BUILD_FOLDER"
    step "Re-generating RAMFS and low-level config" 
    CHROOT='' run_hooks pre-mkinitcpio
    sudo arch-chroot "$R" mkinitcpio -p linux
#}
