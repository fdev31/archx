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

    install_pkg faience-icon-theme
#    install_pkg mint-themes mint-x-icons # TOO SLOW TO LOAD!

    install_pkg ttf-roboto
    # ttf-hack is also an option
    install_pkg ttf-nerd-fonts-hack-complete-git 

#    install_pkg sardi-icons
#    install_pkg flatplat-theme
fi
