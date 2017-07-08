ENV=mate # mate or gnome
NETMGR=networkmanager
PROFILES="$PKG_ALL env-$ENV env-$ENV-apps env-awesome env-gnome"
PREFERRED_TOOLKIT=gtk
DISTRO_PACKAGE_LIST=
DISK_TOTAL_SIZE=4
DISK_SQ_PART=3500 # squashfs part size in MB

function distro_install_hook() {
    if [ ! grep autologin "$R/etc/group" ]; then
        sudo groupadd -R "$R" -r autologin
        sudo gpasswd  -Q "$R" -a user autologin
    fi

    return
}
