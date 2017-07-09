install_pkg  networkmanager
if have_xorg; then  install_pkg  network-manager-applet ; fi
enable_service NetworkManager
