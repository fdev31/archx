if have_xorg ; then
    if [ "$PREFERRED_TOOLKIT" = "qt" ]; then
        install_pkg qtcurve
        install_pkg archlinux-themes-kdm
    else
        install_pkg arc-gtk-theme
        install_pkg vertex-themes
    fi
fi
install_pkg ttf-roboto otf-hack
install_pkg faience-icon-theme
install_pkg sardi-icons
install_pkg breeze-icons
install_pkg breeze-gtk
install_pkg xcursor-pinux
