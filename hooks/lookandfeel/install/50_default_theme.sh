if have_xorg ; then
#    install_pkg osx-arc-white
#    install_pkg capitaine-cursors
    $SUDO tar xf resources/theme.tar.xz -C "$R"
    if [ "$PREFERRED_TOOLKIT" = "qt" ]; then
        install_pkg qtcurve
        install_pkg archlinux-themes-kdm
    else
        install_pkg arc-gtk-theme
    fi
    install_pkg xcursor-pinux
    install_pkg xcursor-oxygen

    install_pkg papirus-icon-theme
    install_pkg moka-icon-theme

    install_pkg ttf-roboto
    install_pkg ttf-hack
    install_pkg noto-fonts
    install_pkg ttf-font-awesome
    install_pkg ttf-fira-code

    install_aur_pkg menda-themes-git
fi
