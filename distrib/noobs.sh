ENV=enlightenment
NETMGR=connman
PROFILES="$PKG_BASE $PKG_XORG env-enlightenment env-enlightenment-apps noobs"
DISK_TOTAL_SIZE=2

PREFERRED_TOOLKIT='gtk'

function distro_install_hook() {
    return
}
