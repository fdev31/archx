enable_service fstrim.timer

if [ -e "$R/etc/udev/hwdb.bin" ]; then
    sudo mv "$R/etc/udev/hwdb.bin" "$R/usr/lib/udev/hwdb.bin"
fi

#if pacman -r "$R" -Qtdq >/dev/null; then
#    sudo pacman --noconfirm -r "$R" -Rns $(pacman  -r "$R" -Qtdq)
#fi

sudo pacman-optimize "$R/var/lib/pacman"
sudo ldconfig -r "$R"

