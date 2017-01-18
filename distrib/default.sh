PROFILES="$PKG_ALL env-awesome env-gnome"
PREFERRED_TOOLKIT=gtk
DISTRO_PACKAGE_LIST='firefox-ublock-origin firefox-download-youtube-videos-as-mp4 dropbox deluge handbrake vlc firefox-flashgot'
function distro_install_hook() {
    sudo sed -i "s/^#user-session=default.*/user-session=gnome/" "$R/etc/lightdm/lightdm.conf"

    # comment out to disable autologin
    sudo sed -i "s/^#autologin-user=.*/autologin-user=user/" "$R/etc/lightdm/lightdm.conf"
    sudo sed -i "s/^#autologin-user-timeout=.*/autologin-user-timeout=5/" "$R/etc/lightdm/lightdm.conf"
    groupadd -R "$R" -r autologin
    gpasswd  -Q "$R" -a user autologin

    return
 }

