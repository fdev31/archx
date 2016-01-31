source ./configuration.sh

function step() {
    echo -e "\\033[44m\\033[1m ------------[   $1   >\\033[0m\\033[49m"
}

function step2() {
    echo -e "\\033[44m ------------[   $1   >\\033[49m"
}

function copy() {
    sudo cp -a "$1"  "$R$1"
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
    sudo sed -i "/^${PATTERN}/,$ d" "${FILE}"
}

function replace_with() {
    PATTERN="$1"
    SUB="$2"
    FILE="$3"
    HEADER=$(sed "/^$PATTERN$/,$ d" "$I")
    FOOTER=$(sed "0,/^$PATTERN END$/ d" "$I")
    echo "$HEADER
$SUB
$FOOTER" | sudo dd of="$I"
}

function install_pkg() {
    if [ -e "$R/bin/$PACMAN_BIN" ]; then
        PKGMGR=$PACMAN_BIN
    else
        PKGMGR="sudo pacman"
    fi
    share_cache
    $PKGMGR -r "$R" --needed $*
    unshare_cache
}

function enable_service() {
    sudo systemctl --root "$R" enable $1
}

function disable_service() {
    sudo systemctl --root "$R" disable $1
}
