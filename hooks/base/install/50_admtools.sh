if [ ! have_package systemd-manager ] ; then
    have_xorg && install_pkg systemd-manager || install_pkg systemd-ui
fi
