source ./configuration.sh

# DETECT LANGUAGE
if [ -z "$DETECT_LOCALE" ] ; then
    IPADDR=$(curl -s icanhazip.com)
    COUNTRY=$(geoiplookup $IPADDR)
    COUNTRY=${COUNTRY#*: }
    COUNTRY=${COUNTRY%%,*}
else
    COUNTRY="EN"
fi

[ -e my_conf.sh ] && source ./my_conf.sh

if [ -z "$COUNTRY" ]; then
    COUNTRY=FR
fi
if [ -e "resources/locales/country_codes/$COUNTRY" ] ; then
    echo "** Adding i18n-$COUNTRY support"
    source resources/locales/country_codes/$COUNTRY
else
    echo "** No i18n support found for $COUNTRY"
fi

HOOK_BUILD_DIR="$WORKDIR/.installed_hooks"
_net_mgr="$HOOK_BUILD_DIR/install/50_network_manager.sh"

# LOAD OVERRIDES

source ./distrib/${DISTRIB}.sh

# i18n @ install time
_gettext_dir=$(realpath ./resources/locales/gettext)

function text() {
    TEXTDOMAIN=messages TEXTDOMAINDIR="$_gettext_dir" gettext "$*"
}


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

function __contains() {
    grep "$1" "$2" > /dev/null
}

function write_text() {
    sudo dd "of=$R/$1"
}
function write_bin() {
    write_text $1
    sudo chmod 755 "$R/$1"
}

function append_text() {
    pat="# GENERATED AT INSTALL:"

    I="$R/$1"

    if __contains "$pat" "$I"; then
        __strip_end "$pat" "$I"
    fi

    _FILE=$(cat "$I")
    _DATA=$(cat /dev/stdin)
    echo "$_FILE

$pat

$_DATA
" | sudo dd "of=$I"
}

function __strip_end() {
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

function make_symlink() {
    sudo ln -fs $1 "$R/$2"
}

function raw_install_pkg() {
    _set_pkgmgr
    $PKGMGR $PKGMGR_OPTS --noconfirm  -r "$R" $* 2>&1 | tee /tmp/pkginst.log
   if [ ${PIPESTATUS[0]} -ne 0 ] ; then
       cat >> /tmp/failedpkgs.log <<EOF
>>>>>>>>>>>>>>>> FAILED to execute $*
$(cat /tmp/pkginst.log)

- end -
EOF
   fi
}

function install_pkg() {
    step2 "Installing $*"
    raw_install_pkg --needed -S $*
}

function remove_pkg() {
    _set_pkgmgr
    $PKGMGR -r "$R" --noconfirm -R $*
}

function network_manager() {
    ln -fs "../../hooks/alternatives/install/network_manager/50_network_$1.sh" "$_net_mgr"
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
function autostart_app() {
    ASDIR="resources/HOME/.config/autostart"
    if [ ! -d "$ASDIR" ]; then
        mkdir "$ASDIR"
    fi
    sudo install -m 644 "$R/usr/share/applications/$1.desktop" "$ASDIR"
}
function no_autostart_app() {
    ASDIR="resources/HOME/.config/autostart"
    if [ ! -d "$ASDIR" ]; then
        mkdir "$ASDIR"
    fi
    sudo install -m 644 "$R/usr/share/applications/$1.desktop" "$ASDIR"
    echo 'X-MATE-Autostart-enabled=false' >> "$ASDIR/$1.desktop"
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
function install_resource() {
    sudo install -m 644 resources/$1 "$R$2"
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
