source ./configuration.sh
source ./distrib/${DISTRIB}.sh

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

PAD_WIDTH=$(tput cols)

if [ -n "$SHARED_CACHE" ]; then
    PKGMGR_OPTS="--cachedir /var/cache/pacman/pkg"
fi

function step() {
    W=$(( $PAD_WIDTH - 5 ))
    printf "\\033[44m\\033[1m    %-${W}s>\\033[0m\\033[49m" "$1"
}

function step2() {
    W=$(( $PAD_WIDTH - 5 ))
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

function raw_install_pkg() {
    if [ -e "$R/bin/$PACMAN_BIN" ]; then
        PKGMGR=$PACMAN_BIN
    else
        PKGMGR="sudo pacman"
    fi
    $PKGMGR $PKGMGR_OPTS -r "$R" $*
}

function install_pkg() {
    step2 "Installing $*"
    raw_install_pkg --needed --noconfirm -S $*
}

function enable_service() {
    sudo systemctl --root "$R" enable $1
}

function disable_service() {
    sudo systemctl --root "$R" disable $1
}
