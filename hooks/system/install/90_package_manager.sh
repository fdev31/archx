if have_xorg ; then
    if [ "$PREFERRED_TOOLKIT" = "qt" ]; then
        install_pkg packagekit-qt5
        install_pkg octopi
    else
        install_pkg gnome-packagekit
        install_pkg pamac-aur
    fi
fi
