source ./configuration.sh

function step() {
    echo -e "\\033[44m\\033[1m ------------[   $1   >\\033[0m\\033[49m"
}
function step2() {
    echo -e "\\033[44m ------------[   $1   >\\033[49m"
}

function copy() {
    cp -a "$1"  "$R$1"
}

function share_cache() {
    if ! mount | grep pacman ; then
        sudo mount --bind /var/cache/pacman/pkg "$R/var/cache/pacman/pkg"
    fi
}

function unshare_cache() {
    sudo umount "$R/var/cache/pacman/pkg"
}

function contains() {
    grep "$1" "$2" > /dev/null
}
function strip_end() {
    PATTERN="$1"
    FILE="$2"
    sed -i "/^${PATTERN}/,$ d" "${FILE}"
}

function install_pkg() {
    if [ -e "$R/bin/yaourt" ]; then
        PKGMGR=yaourt
    else
        PKGMGR=pacman
    fi
    share_cache
    sudo $PKGMGR -r "$R" --needed $*
    unshare_cache
}
