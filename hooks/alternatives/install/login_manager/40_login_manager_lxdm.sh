install_pkg lxdm
install_pkg archlinux-lxdm-theme-full
sudo sed -i "s#/usr/bin/startlxde#/bin/$ENV-session#" "$R/etc/lxdm/lxdm.conf"
sudo sed -i "s#Adwaita#Breeze#" "$R/etc/lxdm/lxdm.conf"
sudo sed -i "s#Industrial#Archlinux#" "$R/etc/lxdm/lxdm.conf"
enable_service lxdm
