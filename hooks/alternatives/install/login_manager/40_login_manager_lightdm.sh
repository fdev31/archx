#if [ "$PREFERRED_TOOLKIT" = "gtk" ]; then
#    install_pkg  lightdm-gtk-greeter
#else
#    install_pkg  lightdm-kde-greeter
#fi
install_pkg  lightdm-gtk-greeter

$SUDO mkdir "$R/run/lightdm" 2> /dev/null # fix warning

install_pkg  lightdm

enable_service lightdm

$SUDO sed -i "s/^#user-session=.*/user-session=$ENV/" "$R/etc/lightdm/lightdm.conf"

# comment out to disable autologin
$SUDO sed -i "s/^#autologin-user=.*/autologin-user=user/" "$R/etc/lightdm/lightdm.conf"
$SUDO sed -i "s/^#autologin-user-timeout=.*/autologin-user-timeout=10/" "$R/etc/lightdm/lightdm.conf"
$SUDO sed -i "s/^#autologin-in-background=.*/autologin-in-background=true/" "$R/etc/lightdm/lightdm.conf"
