if [ "$PREFERRED_TOOLKIT" = "gtk" ]; then
    install_pkg  lightdm-gtk-greeter
else
    install_pkg  lightdm-kde-greeter
fi

sudo mkdir "$R/run/lightdm" 2> /dev/null # fix warning

install_pkg  lightdm

enable_service lightdm
