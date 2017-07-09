install_pkg grub
install_pkg efibootmgr
install_pkg mtools
install_pkg testdisk
install_pkg rsync
install_pkg file
install_pkg nmap
install_pkg sleuthkit
if have_xorg; then  install_pkg gparted ; fi
