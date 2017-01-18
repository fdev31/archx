if [ have_xorg ]; then
    install_pkg avidemux-qt
    sudo chmod a+rx "$R/usr/lib/libADM6"*
fi
