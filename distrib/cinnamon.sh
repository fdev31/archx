ENV=cinnamon
NETMGR=netctl
PROFILES="$PKG_ALL env-$ENV env-$ENV-apps"
DISK_TOTAL_SIZE=4

PREFERRED_TOOLKIT='gtk'

DISTRO_PACKAGE_LIST=

function distro_install_hook() {
    return
}
