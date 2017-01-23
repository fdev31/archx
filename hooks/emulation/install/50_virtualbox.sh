if have_xorg ; then
    install_pkg virtualbox
    install_pkg linux-headers # needed for dkms
    install_pkg virtualbox-host-dkms
fi
