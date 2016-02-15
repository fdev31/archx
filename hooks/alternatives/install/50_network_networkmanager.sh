
install_pkg  networkmanager

have_xorg && install_pkg  network-manager-applet

sudo systemctl --root "$R" enable NetworkManager
