#!/bin/sh

if [ -z "$1" ]; then
    echo "Syntax: $0 <profile name>"
    exit
fi

PROF_NAME="$1"

shift

HOOK=$1


if [ ! -z "$HOOK" ]; then
    dest=$(echo $HOOK | cut -d/ -f3)
    hookname=$(basename $HOOK)
    ln -s "../../$HOOK" "${PROF_NAME}/$dest/$hookname"
    exit
fi

mkdir "$PROF_NAME" 2>/dev/null || (echo "Profile exists!" && exit)

cd "$PROF_NAME"

for name in $(find ../all/ -name "*.sh" | sort); do
    # TODO: auto import "script-forced" scripts
    echo ${name:7:-3} | sed -E -e 's#/([0-9]{2}_)?# #g' -e 's/^(.*) (.*) (.*)$/\1:  \3  (\2)/'
    echo -n "Import (Y/n) ? "
    read yn
    if [ "$yn" != "n" ]; then
        hooktype=$( echo ${name:7:-3} | sed -E -e 's#/([0-9]{2}_)?# #g' -e 's/^(.*) (.*) (.*)$/\2/' )
        if [ ! -d "$hooktype" ]; then
            mkdir "$hooktype"
        fi
        ln -s "../$name" "$hooktype/"
    fi
done
