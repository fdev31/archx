
install_pkg  lightdm

sudo mkdir "$R/run/lightdm" 2> /dev/null # fix warning

if [ "$PREFERRED_TOOLKIT" = "gtk" ]; then
    install_pkg  lightdm-gtk-greeter
else
    install_pkg  lightdm-kde-greeter
fi

enable_service lightdm
