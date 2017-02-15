ENV=mate # mate or gnome
NETMGR=networkmanager
PROFILES="$PKG_ALL env-$ENV env-$ENV-apps env-awesome env-gnome"
PREFERRED_TOOLKIT=gtk
DISTRO_PACKAGE_LIST=
DISK_TOTAL_SIZE=4

function distro_install_hook() {
    echo "Writing $R/home/$USERNAME/.dmrc"

    cat > "$R/home/$USERNAME/.dmrc" <<EOF 
[Desktop]
Language=$LANG
Session=$ENV
EOF
    sudo groupadd -R "$R" -r autologin
    sudo gpasswd  -Q "$R" -a user autologin

    return
}
