PROFILES="base locales" # system installer

PREFERRED_TOOLKIT='gtk'

function distro_install_hook() {
    sudo systemctl --root ROOT set-default multi-user.target # not graphical
    return
}
