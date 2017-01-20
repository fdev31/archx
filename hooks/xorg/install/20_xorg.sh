
install_pkg xorg
install_pkg xorg-xinit
install_pkg accountsservice

enable_service accounts-daemon
if [ "$PREFERRED_TOOLKIT" = "gtk" ]; then
    install_pkg gtk-engines
    install_pkg gnome-vfs
fi

install_pkg libx264 mesa-libgl
install_pkg mesa-libgl
install_pkg lib32-mesa-libgl
install_pkg libva-vdpau-driver
install_pkg libva-intel-driver
install_pkg mesa-vdpau
install_pkg libvdpau
install_pkg gnome-keyring
