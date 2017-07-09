install_pkg bluez
if have_xorg; then  install_pkg blueman ; fi
enable_service bluetooth
