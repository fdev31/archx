ENV=mate # mate or gnome
PROFILES="$PKG_ALL env-awesome env-$ENV"
PREFERRED_TOOLKIT=gtk
DISTRO_PACKAGE_LIST='firefox-ublock-origin firefox-download-youtube-videos-as-mp4 dropbox deluge handbrake vlc firefox-flashgot'
DISK_TOTAL_SIZE=4

function distro_install_hook() {
    sudo sed -i "s/^#user-session=.*/user-session=$ENV/" "$R/etc/lightdm/lightdm.conf"

    # comment out to disable autologin
    sudo sed -i "s/^#autologin-user=.*/autologin-user=user/" "$R/etc/lightdm/lightdm.conf"
    sudo sed -i "s/^#autologin-user-timeout=.*/autologin-user-timeout=10/" "$R/etc/lightdm/lightdm.conf"
    sudo sed -i "s/^#autologin-in-background=.*/autologin-in-background=true/" "$R/etc/lightdm/lightdm.conf"

    sudo groupadd -R "$R" -r autologin
    sudo gpasswd  -Q "$R" -a user autologin

    return
}
