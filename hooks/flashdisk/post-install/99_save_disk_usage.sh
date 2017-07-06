$SUDO du -s "$R" | cut -d '	' -f 1 > .diskusage
if [ -z "$CHROOT" ]; then
    $SUDO mv .diskusage "$R/.diskusage"
fi
