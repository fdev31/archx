install_pkg pulseaudio-bluetooth
install_pkg pulseaudio-equalizer
install_pkg pulseaudio-zeroconf
if have_xorg ; then
    install_pkg paman
    install_pkg pavucontrol
    install_pkg pavumeter
    install_pkg paprefs
    install_pkg wayland-protocols-git
    install_pkg pasystray
fi
