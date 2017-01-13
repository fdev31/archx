if have_xorg ; then
    if [ "$PREFERRED_TOOLKIT" = "qt" ]; then
        install_pkg qtcurve
        install_pkg archlinux-themes-kdm
    else
        install_pkg arc-gtk-theme
        install_pkg vertex-themes
        install_pkg xcursor-archcursorblue
        install_pkg xcursor-pinux
        install_pkg sardi-icons
    fi
fi
