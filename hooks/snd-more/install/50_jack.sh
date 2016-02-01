. ./strapfuncs.sh

install_pkg jack2
install_pkg pulseaudio-jack

if [ "$PREFERRED_TOOLKIT" = "qt" ]; then
    install_pkg qjackctl
else

install_pkg patchage

