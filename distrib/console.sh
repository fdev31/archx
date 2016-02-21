PROFILES="base locales" # system installer

DISK_MARGIN=10 # extra space for persistence, also HOME size, used for loopback or disk images
BOOT_MARGIN=30 # extra space for /boot (first partition)
BOOT_TARGET="multi-user"

function distro_install_hook() {
    sudo systemctl --root ROOT set-default multi-user.target # not graphical
    return
}
