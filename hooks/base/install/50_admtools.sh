if have_xorg && ! have_package systemd-manager ; then
    install_pkg systemd-manager || install_pkg systemd-ui
fi
