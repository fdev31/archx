
install_pkg  xorg xterm xorg-xinit

install_resource xorg/*.conf /etc/X11/xorg.conf.d/
sudo sed -i "s/fr/$LANG_ISO2/" /etc/X11/xorg.conf.d/10-keyboard-layout.conf


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

install_pkg xcursor-oxygen
