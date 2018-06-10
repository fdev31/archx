enable_service fstrim.timer

if [ -e "$R/etc/udev/hwdb.bin" ]; then
    $SUDO mv "$R/etc/udev/hwdb.bin" "$R/usr/lib/udev/hwdb.bin"
fi

if pacman -r "$R" -Qtdq >/dev/null; then
    $SUDO pacman --noconfirm --sysroot "$R" -Rns $(pacman  -r "$R" -Qtdq)
fi
$SUDO pacman --noconfirm --sysroot "$R" -Sc

#$SUDO pacman-optimize "$R/var/lib/pacman"
$SUDO ldconfig -r "$R"

$SUDO rm -fr "$R/var/cache/pacman/pkg/"*
rm -fr "$R/home/user/.cache/"*
