. ./strapfuncs.sh

install_pkg  lightdm

if [ "$PREFERRED_TOOLKIT" = "gtk" ]; then
    install_pkg  lightdm-gtk-greeter
else
    install_pkg  lightdm-kde-greeter
fi

enable_service lightdm
