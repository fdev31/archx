#!/usr/bin/env sh
# Makes a compressed root filesystem image using squashfs

if [ ! -e configuration.sh ]; then
    echo "This script must be executed from its own original folder"
    exit 1
fi

source ./strapfuncs.sh
# vars:

step "Cleaning FS & building SQUASHFS ($COMPRESSION_TYPE)"
IF=../ignored.files
pushd "$R" >/dev/null || exit -2
ls *.sh > $IF
ls *.py || true >> $IF
sudo find resources/ > $IF
sudo find boot/ | sed 1d >> $IF
sudo find var/cache/ | sed 1d >> $IF
sudo find run/ | sed 1d >> $IF
sudo find var/run/ -type f >> $IF
sudo find var/log/ -type f >> $IF

sudo find proc/ | sed 1d >> $IF
sudo find sys/ | sed 1d >> $IF
sudo find dev/ -type f >> $IF

if [ ! -d ".$LIVE_SYSTEM" ]; then
    sudo mkdir ".$LIVE_SYSTEM"
fi


make_squashfs "$SQ" "$IF"

sudo rm -fr $IF
popd > /dev/null
