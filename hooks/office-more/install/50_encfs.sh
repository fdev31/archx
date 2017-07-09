install_pkg encfs
if have_xorg; then  install_pkg cryptkeeper ; fi
if have_xorg; then  autostart_app cryptkeeper ; fi
