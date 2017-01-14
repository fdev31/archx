if have_xorg ; then
    if [ "$PREFERRED_TOOLKIT" = "qt" ]; then
        install_pkg packagekit-qt5
        install_pkg plasma-pk-updates-git
        install_pkg apper
#        install_pkg octopi # may replace pamac-aur
    else
        install_pkg gnome-packagekit
    fi
    install_pkg pamac-aur
fi
