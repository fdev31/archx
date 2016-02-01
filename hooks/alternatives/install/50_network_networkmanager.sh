. ./strapfuncs.sh

install_pkg  networkmanager

sudo systemctl --root "$R" enable NetworkManager
