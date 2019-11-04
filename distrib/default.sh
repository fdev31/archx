ENV=mate # mate or gnome
NETMGR=networkmanager
PROFILES="$PKG_ALL env-awesome"
PREFERRED_TOOLKIT=gtk
DISTRO_PACKAGE_LIST=""
DISK_TOTAL_SIZE=4
DISK_SQ_PART=3500 # squashfs part size in MB

function distro_install_hook() {
    if [ ! grep autologin "$R/etc/group" ]; then
        sudo groupadd -R "$R" -r autologin
        sudo gpasswd  -Q "$R" -a user autologin
    fi

    return
}


# should fit into
#BOOT/EFI: 100M
#OS: 3500M
#RW: 400M
