#!/usr/bin/env sh
set -e

if [ ! -e configuration.sh ]; then
    echo "This script must be executed from its own original folder"
    exit 1
fi

source ./strapfuncs.sh
# vars:
# R HOOK_BUILD_FOLDER DISTRIB DISTRO_PACKAGE_LIST  BOOT_TARGET



    HOOK_BUILD_DIR="$R/$HOOK_BUILD_FOLDER"
    (sudo cp -r strapfuncs.sh configuration.sh resources/onelinelog.py resources my_conf.sh distrib/$DISTRIB.sh "$R")
    if [ -e my_conf.sh ] ; then
        sudo cp my_conf.sh "$R"
    fi
    sudo rm -fr "$HOOK_BUILD_DIR" 2> /dev/null
    step "Installing pacman hooks"
    sudo mkdir -p "$R/etc/pacman.d/hooks"
    sudo cp -r resources/pacmanhooks "$R/etc/pacman.d/hooks"
    step "Triggering install hooks"
    run_hooks pre-install
    step " Network setup "
    run_hooks install
    if [ -n "$DISTRO_PACKAGE_LIST" ]; then
        step2 "Distribution packages"
        for pkg in $DISTRO_PACKAGE_LIST; do
            install_pkg "$pkg"
        done
    fi


# FIXME: doesn't like to be in a chroot
function install_extra_packages() {
    step2 "Extra packages"
    sudo cp -r extra_packages "$R"
    $SU_ARCHCHROOT /extra_packages/install.sh
    sudo rm -fr "$R/extra_packages"
}

    distro_install_hook
    sudo systemctl --root ROOT set-default ${BOOT_TARGET}.target
    run_hooks post-install
    (cd "$R" && sudo rm -fr strapfuncs.sh configuration.sh resources/onelinelog.py resources $DISTRIB.sh)
    if [ -e my_conf.sh ] ; then
        sudo rm "$R/my_conf.sh"
    fi
    sudo mv "$R/stdout.log" .

