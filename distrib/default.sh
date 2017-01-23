ENV=mate # mate or gnome
PROFILES="$PKG_ALL env-$ENV env-$ENV-apps"
PREFERRED_TOOLKIT=gtk
DISTRO_PACKAGE_LIST=
DISK_TOTAL_SIZE=4

function distro_install_hook() {
    sudo sed -i "s/^#user-session=.*/user-session=$ENV/" "$R/etc/lightdm/lightdm.conf"

    # comment out to disable autologin
    sudo sed -i "s/^#autologin-user=.*/autologin-user=user/" "$R/etc/lightdm/lightdm.conf"
    sudo sed -i "s/^#autologin-user-timeout=.*/autologin-user-timeout=10/" "$R/etc/lightdm/lightdm.conf"
    sudo sed -i "s/^#autologin-in-background=.*/autologin-in-background=true/" "$R/etc/lightdm/lightdm.conf"

    sudo groupadd -R "$R" -r autologin
    sudo gpasswd  -Q "$R" -a user autologin

    cat > $R/home/$USERNAME/.dmrc <<EOF 
[Desktop]
Language=$LANG
Session=$ENV
EOF

    return
}
