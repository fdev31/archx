install_pkg --asdeps gst-libav
install_pkg --asdeps tracker
install_pkg rygel
install_pkg eezupnp
if have_xorg ; then # totem client
   install_pkg dleyna-server
   install_pkg gupnp-av
   install_pkg grilo-plugins
fi
