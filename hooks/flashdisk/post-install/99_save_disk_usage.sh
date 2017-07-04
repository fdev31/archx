$SUDO du -s "$R" | cut -d '	' -f 1 > .diskusage
$SUDO mv .diskusage "$R/.diskusage"
