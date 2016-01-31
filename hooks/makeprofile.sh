#!/bin/bash

if [ -z "$1" ]; then
    echo "Syntax: $0 <profile name>"
    exit
fi

PROF_NAME="$1"

shift

HOOK=$1


if [ ! -z "$HOOK" ]; then
    DEST="${HOOK%/*}"
    DEST="${DEST##*/}"
    HOOKNAME=${HOOK##*/}
    if [ ! -d "${PROF_NAME}/$DEST" ]; then
        mkdir "${PROF_NAME}/$DEST"
    fi
    ln -sf "../../$HOOK" "${PROF_NAME}/$DEST/$HOOKNAME"
    exit
fi

mkdir "$PROF_NAME" 2>/dev/null || (echo "Profile exists!" && exit)

cd "$PROF_NAME"

for NAME in $(find ../all/ -name "*.sh" | sort); do
    # TODO: auto import "script-forced" scripts
    CAT="${NAME#*all/}"
    CAT="${CAT%%/*}"
    if [ "$CAT" = "$SKIP" ]; then
        continue
    fi
    TYPE="${NAME#*$CAT/}"
    TYPE="${TYPE%%/*}"
    SHORT="${NAME##*/}"
    SHORT="${SHORT#*_}"
    SHORT="${SHORT%.*}"
    echo "####################################################################"
    echo "$CAT   =$SHORT=    ($TYPE)"
    grep -v strapfuncs $NAME
    echo -n "Import (Y/n/t/s) ? "
    read yn
    if [ "$yn" = "t" ]; then
        exit 0
    fi
    if [ "$yn" = "s" ]; then
        SKIP=$CAT
        continue
    fi
    if [ "$yn" != "n" ]; then
        if [ ! -d "$TYPE" ]; then
            mkdir "$TYPE"
        fi
        ln -sf "../$NAME" "$TYPE/"
    fi
done
