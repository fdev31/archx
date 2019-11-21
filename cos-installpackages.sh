#!/usr/bin/env sh
# Main installer script for most packages
# - install pacmanhooks
# - RUN pre-install hooks
# - RUN install hooks
# - RUN install of DISTRO_PACKAGE_LIST
# - RUN distro_install_hook
# - set the BOOT_TARGET
# - RUN post-install hooks

if [ ! -e configuration.sh ]; then
    echo "This script must be executed from its own original folder"
    exit 1
fi

source ./strapfuncs.sh
source ./coslib.sh
# vars:
# R HOOK_BUILD_FOLDER DISTRIB DISTRO_PACKAGE_LIST  BOOT_TARGET

HOOK_BUILD_DIR="$R/$HOOK_BUILD_FOLDER"
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

distro_install_hook
sudo systemctl --root ROOT set-default ${BOOT_TARGET}.target
run_hooks post-install

sudo mv "$R/stdout.log" .

