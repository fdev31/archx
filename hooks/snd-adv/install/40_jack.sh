install_pkg jack2
install_pkg pulseaudio-jack
install_pkg libflashsupport-jack
if have_xorg; then  install_pkg qjackctl ; fi
if have_xorg; then  install_pkg patchage ; fi
