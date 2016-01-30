source ./configuration.sh

if [ -e "$R/etc/udev/hwdb.bin" ]; then
    mv "$R/etc/udev/hwdb.bin" "$R/usr/lib/udev/hwdb.bin"
fi

pacman-optimize "$R/var/lib/pacman"
ldconfig -r "$R"
