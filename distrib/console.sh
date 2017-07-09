PROFILES="base locales flashdisk editors"
NETMGR=netctl

DISK_MARGIN=50 # extra space for persistence, also HOME size, used for loopback or disk images
BOOT_TARGET="multi-user"

function distro_install_hook() {
    sudo systemctl --root ROOT set-default multi-user.target # not graphical
    return
}
