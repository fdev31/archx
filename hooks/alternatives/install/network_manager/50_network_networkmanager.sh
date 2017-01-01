
install_pkg  networkmanager

have_xorg && install_pkg  network-manager-applet

enable_service NetworkManager
