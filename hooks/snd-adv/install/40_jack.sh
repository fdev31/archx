
install_pkg jack2
install_pkg pulseaudio-jack
install_pkg libflashsupport-jack

if [ "$PREFERRED_TOOLKIT" = "qt" ]; then
    install_pkg qjackctl
else

install_pkg patchage
