PROFILES="base xorg snd-base env-awesome"

PREFERRED_TOOLKIT='gtk'

DISTRO_PACKAGE_LIST='gvim'

function distro_install_hook() {
    sudo chown -R 1000 "$R/home/$USERNAME"
    return
}
