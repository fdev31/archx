
install_pkg  xorg xterm xorg-xinit

copy /etc/X11/xorg.conf.d/00-keyboard.conf
copy /etc/X11/xorg.conf.d/10-keyboard-layout.conf

enable_service accounts-daemon
if [ "$PREFERRED_TOOLKIT" = "gtk" ]; then
    install_pkg gtk-engines
    install_pkg gnome-vfs
fi

install_pkg libx264 mesa-libgl
install_pkg nouveau-fw
install_pkg libva-vdpau-driver
install_pkg libva-intel-driver
install_pkg mesa-vdpau
install_pkg libvdpau
