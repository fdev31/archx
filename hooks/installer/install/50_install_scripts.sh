install_pkg arch-install-scripts
install_bin resources/installer.py /bin/
install_bin resources/mkparts.sh /bin/installer-standard.sh
install_bin resources/installhere.sh /bin/installer-embed.sh
install_bin resources/mkarch.sh /bin/installer-archlinux.sh
sudo mkdir -p "$R/usr/share/installer"
install_bin resources/instlib.sh /usr/share/installer
install_pkg parted # used for partprobe

install_pkg python-pythondialog

echo "#!/bin/sh
mount /boot -o remount,rw
cp $* /boot/
mount /boot -o remount,ro
" | sudo dd of="$R/bin/copy2boot.sh"
sudo chmod +x "$R/bin/copy2boot.sh"
