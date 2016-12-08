source ./configuration.sh

# DETECT LANGUAGE

IPADDR=$(curl -s icanhazip.com)
COUNTRY=$(geoiplookup $IPADDR)
COUNTRY=${COUNTRY#*: }
COUNTRY=${COUNTRY%,*}
if [ -e country_codes/$COUNTRY ] ; then
    echo "** Adding i18n-$COUNTRY support"
    source country_codes/$COUNTRY
else
    echo "** No i18n support found for $COUNTRY"
fi

# LOAD OVERRIDES

[ -e my_conf.sh ] && source ./my_conf.sh

source ./distrib/${DISTRIB}.sh

# AUTO ADD FLASHDISK IF LIVESYSTEM

if [ -n "$USE_LIVE_SYSTEM" ] && [[ "$PROFILES" != *flashdisk ]] ; then
    PROFILES="${PROFILES} flashdisk"
fi

# FONCTION DEFINITION

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

function append() {
	orig=$(cat $1)
	echo "$orig
$2
" | sudo dd "of=$1"
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

function make_symlink() {
    sudo ln -fs $1 "$R/$2"
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

function install_bin() {
    sudo install -m 755 -o root -g root "$1" "$R$2"
}
function install_file() {
    sudo install -m 644 -o root -g root "$1" "$R$2"
}

function extended_install_file () {
    xx=$2
    sudo cp -a "$1" "/tmp/ext.tmp"
    sed -i "/tmp/ext.tmp" \
        -e "s#{{ROOTIMAGE}}#$ROOTNAME#" \
        -e "s#{{DISKLABEL}}#$DISKLABEL#" \
        -e "s#{{STORAGE_PATH}}#$LIVE_SYSTEM#" \
        -e "s#{{STORAGE}}#rootfs.$ROOT_TYPE#"
    install_file "/tmp/ext.tmp" "$xx"
    sudo rm /tmp/ext.tmp
}



function autostart_app() {
    ASDIR="resources/HOME/.config/autostart"
    if [ ! -d "$ASDIR" ]; then
        mkdir "$ASDIR"
    fi
    sudo install -m 644 "$R/usr/share/applications/$1.desktop" "$ASDIR"
}
function install_menu () {
    ASDIR="resources/HOME/.config/menus"
    if [ ! -d "$ASDIR" ]; then
        mkdir "$ASDIR"
    fi
    sudo install -m 644 "resources/menus/$1.menu" "$ASDIR"
}
function install_application() {
    ASDIR="resources/HOME/.local/share/applications"
    if [ ! -d "$ASDIR" ]; then
        mkdir "$ASDIR"
    fi
    sudo install -m 644 resources/applications/$1.desktop "$ASDIR"
}

function _set_pkgmgr() {
    if [ -e "$R/bin/$PACMAN_BIN" ]; then
        PKGMGR=$PACMAN_BIN
    else
        PKGMGR="sudo pacman"
    fi
}

function set_user_ownership() {
    sudo chown -R $USERID.$USERGID $*
}
