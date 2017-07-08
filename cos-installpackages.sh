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
    (sudo cp -r strapfuncs.sh configuration.sh onelinelog.py resources my_conf.sh distrib/$DISTRIB.sh "$R")
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
        install_pkg $DISTRO_PACKAGE_LIST
    fi

    # TODO: rewrite this:
#function install_extra_packages() {
#    step2 "Extra packages"
#    sudo cp -r extra_packages "$R"
#    return
#    if [ -e "extra_packages/dependencies.txt" ]; then
#        sudo pacman -r "$R" -S --needed --noconfirm $(cat extra_packages/dependencies.txt)
#    else
#        echo "No extra packages dependencies declared"
#    fi
#    if [ -z "$NO_EXTRA_PACKAGES" ] && ls extra_packages/*pkg.tar* >/dev/null 2>&1 ; then
#        sudo pacman -r "$R" -U --needed --noconfirm extra_packages/*pkg.tar*
#    fi
#    sudo rm -fr "$R/extra_packages"
#}

    distro_install_hook
    sudo systemctl --root ROOT set-default ${BOOT_TARGET}.target
    run_hooks post-install
    (cd "$R" && sudo rm -fr strapfuncs.sh configuration.sh onelinelog.py resources $DISTRIB.sh)
    if [ -e my_conf.sh ] ; then
        sudo rm "$R/my_conf.sh"
    fi
    sudo mv "$R/stdout.log" .

