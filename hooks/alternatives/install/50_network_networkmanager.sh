. ./strapfuncs.sh

install_pkg -Sy --noconfirm networkmanager

sudo systemctl --root "$R" enable NetworkManager
