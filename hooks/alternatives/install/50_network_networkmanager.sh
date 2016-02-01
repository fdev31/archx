. ./strapfuncs.sh

install_pkg  networkmanager

if [[ "$PROFILES" = *xorg* ]]; then
    install_pkg  network-manager-applet
fi

sudo systemctl --root "$R" enable NetworkManager
