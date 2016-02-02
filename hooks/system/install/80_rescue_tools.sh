. ./strapfuncs.sh

install_pkg grub efibootmgr mtools testdisk rsync file nmap 

if [[ "$PROFILES" = *xorg* ]]; then
    install_pkg gparted
fi
