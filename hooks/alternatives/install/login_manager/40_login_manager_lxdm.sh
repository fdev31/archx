install_pkg lxdm
install_pkg archlinux-lxdm-theme-full
sudo sed -i "s#^.*autologin=.*#autologin=user#" "$R/etc/lxdm/lxdm.conf"
sudo sed -i "s#^.*timeout=.*#timeout=5#" "$R/etc/lxdm/lxdm.conf"
sudo sed -i "s@# session=.*@session=/bin/$ENV-session@" "$R/etc/lxdm/lxdm.conf"
sudo sed -i "s#Adwaita#Breeze#" "$R/etc/lxdm/lxdm.conf"
sudo sed -i "s#Industrial#Archlinux#" "$R/etc/lxdm/lxdm.conf"
enable_service lxdm
