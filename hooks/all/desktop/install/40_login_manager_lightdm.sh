source ./configuration.sh


./mkbootstrap.sh install -S  --noconfirm lightdm

if [ "$PREFERRED_TOOLKIT" = "gtk" ]; then
    ./mkbootstrap.sh install -S  --noconfirm lightdm-gtk-greeter
else
    ./mkbootstrap.sh install -S  --noconfirm lightdm-kde-greeter
fi

ln -sf /usr/lib/systemd/system/lightdm.service $R/etc/systemd/system/display-manager.service
