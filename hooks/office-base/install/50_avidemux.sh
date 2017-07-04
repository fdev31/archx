if have_xorg ; then
    install_pkg avidemux-qt
    $SUDO chmod a+rx "$R/usr/lib/libADM6"*
fi
