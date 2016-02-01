source ./strapfuncs.sh

enable_service fstrim.timer

if [ -e "$R/etc/udev/hwdb.bin" ]; then
    sudo mv "$R/etc/udev/hwdb.bin" "$R/usr/lib/udev/hwdb.bin"
fi

pacman --noconfirm -r "$R" -Rns $(pacman  -r "$R"-Qtdq)

sudo pacman-optimize "$R/var/lib/pacman"
sudo ldconfig -r "$R"

