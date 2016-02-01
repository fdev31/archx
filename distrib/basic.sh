PROFILES="base xorg gfx-base office-base env-enlightenment"

PREFERRED_TOOLKIT='gtk'

DISTRO_PACKAGE_LIST='scite gvim lxappearance'

function distro_install_hook() {
    sudo tar xvf resources/home.txz -C "$R/home/$USERNAME/"
}
