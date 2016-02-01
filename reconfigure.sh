#!/bin/sh

RESULT=
CONFIG=""

function append_conf() {
    CONFIG="${CONFIG}\n${*}"
}

function ask() {
    echo -n "$1: "
    read RESULT
}

function disp_choice() {
    PARAM="$*"
    CNT=1
    for P in ${PARAM[@]} ; do
        echo " ${CNT} - ${P}"
        CNT=$(($CNT + 1))
    done
}

function get_choice() {
    TXT=${1}
    shift
    disp_choice "${@}"
    ask "$TXT"
    RESULT="${!RESULT}"
}

DISTRIBS=('custom')
CNT=1
for DIST in distrib/*.sh ; do
    NAME=${DIST##*/}
    NAME=${NAME%.*}
    DISTRIBS[$CNT]="$NAME"
    CNT=$(($CNT + 1))
done

get_choice "What distrib do you chose" ${DISTRIBS[@]}
append_conf "DISTRIB=$RESULT"

if [ "$RESULT" = "custom" ]; then
    OUT="./distrib/custom.sh"
    PROFILES="base"
    ask "Do you want a graphical user interface [X11/xorg] (Y/n)"
    if [ "$RESULT" != "n" ]; then
        PROFILES="$PROFILES xorg"
        CHOICES=()
        CNT=1
        for PROFILE in hooks/env-*; do
            NAME=${PROFILE##*/}
            CHOICES[$CNT]=${NAME#env-}
            CNT=$(($CNT + 1))
        done
        get_choice "Which Desktop " "${CHOICES[@]}"
        PROFILES="$PROFILES env-$RESULT"
        ask "Do you want Emulators support (Y/n)"
        if [ "$RESULT" != "n" ]; then
            PROFILES="$PROFILES emulation"
        fi
        ask "Do you want Network tools (Y/n)"
        if [ "$RESULT" != "n" ]; then
            PROFILES="$PROFILES net-utils"
        fi
        ask "Do you want system/recovery tools (Y/n)"
        if [ "$RESULT" != "n" ]; then
            PROFILES="$PROFILES system"
        fi
        ask "Do you want basic development tools (Y/n)"
        if [ "$RESULT" != "n" ]; then
            PROFILES="$PROFILES dev-base"
        fi
        ask "Do you want basic sound tools (Y/n)"
        if [ "$RESULT" != "n" ]; then
            PROFILES="$PROFILES snd-base"
            ask "Do you want advanced sound tools (Y/n)"
            if [ "$RESULT" != "n" ]; then
                PROFILES="$PROFILES snd-more"
            fi
        fi
        ask "Do you want graphic tools (Y/n)"
        if [ "$RESULT" != "n" ]; then
            PROFILES="$PROFILES gfx-base"
            ask "Do you want graphic design tools (Y/n)"
            if [ "$RESULT" != "n" ]; then
                PROFILES="$PROFILES gfx-more"
            fi
            ask "Do you want photography tools (Y/n)"
            if [ "$RESULT" != "n" ]; then
                PROFILES="$PROFILES photo-base"
            fi
        fi
        ask "Do you want Office tools (Y/n)"
        if [ "$RESULT" != "n" ]; then
            PROFILES="$PROFILES office-base"
        fi
        ask "Do you have a scanner or a printer and use it (Y/n)"
        if [ "$RESULT" != "n" ]; then
            PROFILES="$PROFILES office-more"
        fi
    fi
    echo "PROFILES='$PROFILES'" > $OUT
    if [[ "$PROFILES" == *kde* ]] ; then
        echo "PREFERRED_TOOLKIT=qt" >> $OUT
    else
        echo "PREFERRED_TOOLKIT=gtk" >> $OUT
    fi
    ask "Enter name of additional software you may use (eg. skype flashplugin)"
    echo "DISTRO_PACKAGE_LIST='$RESULT'" >> $OUT
    echo 'function distro_install_hook() {
    return
}
    ' >> $OUT
fi

ask "Name for this distro (only ascii, no spaces)"
append_conf "DISKLABEL=$RESULT"

ask "User id/login"
append_conf "USERNAME=$RESULT"
ask "Password"
append_conf "PASSWORD=$RESULT"

if [ -z "$OUT" ]; then
    echo -e $CONFIG >> $OUT
else
    CFG=configuration.sh
    if grep "RECONFIG SCRIPT" $CFG >/dev/null 2>&1 ; then
        sed -i '/^# RECONFIG/,$ d' $CFG
    fi
    echo "# RECONFIG SCRIPT" >> $CFG
    echo -e $CONFIG >> $CFG
fi


