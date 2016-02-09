source ./configuration.sh
source ./distrib/${DISTRIB}.sh

[ -e my_conf.sh ] && source ./my_conf.sh

if [ -n "$LIVE_SYSTEM" ] && [[ "$PROFILES" != *flashdisk ]] ; then
    PROFILES="${PROFILES} flashdisk"
fi

function have_xorg() {
    if [[ "$PROFILES" = *xorg* ]]; then
        return 0
    else
        return 1
    fi
}

if [ -n "$SHARED_CACHE" ]; then
    PKGMGR_OPTS="--cachedir /var/cache/pacman/pkg"
fi

function step() {
    W=$(( $(tput cols) - 5 ))
    printf "\\033[44m\\033[1m    %-${W}s>\\033[0m\\033[49m" "$1"
}

function step2() {
    W=$(( $(tput cols) - 5 ))
    printf "\\033[44m    %-${W}s>\\033[0m" "$1"
}

function copy() {
    sudo cp -a "$1"  "$R$1"
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
    FOOTER=$(sed "0,/^$PATTERN END/ d" "$I")
    echo "$HEADER
$SUB
$FOOTER" | sudo dd of="$I"
}

function have_package() {
    _set_pkgmgr
    $PKGMGR $PKGMGR_OPTS -r "$R" -Qqq $* >/dev/null 2>&1
}

function raw_install_pkg() {
    _set_pkgmgr
    $PKGMGR $PKGMGR_OPTS -r "$R" $*
}

function install_pkg() {
    step2 "Installing $*"
    raw_install_pkg --needed --noconfirm -S $*
}

function remove_pkg() {
    _set_pkgmgr
    $PKGMGR -r "$R" --noconfirm -R $*
}

function enable_service() {
    sudo systemctl --root "$R" --force enable $1
}

function disable_service() {
    sudo systemctl --root "$R" disable $1
}

function _set_pkgmgr() {
    if [ -e "$R/bin/$PACMAN_BIN" ]; then
        PKGMGR=$PACMAN_BIN
    else
        PKGMGR="sudo pacman"
    fi
}
