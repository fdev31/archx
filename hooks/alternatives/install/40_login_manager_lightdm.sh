. ./strapfuncs.sh

install_pkg -S --noconfirm lightdm

if [ "$PREFERRED_TOOLKIT" = "gtk" ]; then
    install_pkg -S  --noconfirm lightdm-gtk-greeter
else
    install_pkg -S  --noconfirm lightdm-kde-greeter
fi

enable_service lightdm
