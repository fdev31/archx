install_pkg arch-install-scripts
install_bin resources/install2disk.sh /bin/

install_pkg python-pythondialog

echo "#!/bin/sh
mount /boot -o remount,rw
cp $* /boot/
mount /boot -o remount,ro
" | sudo dd of="$R/bin/copy2boot.sh"
sudo chmod +x "$R/bin/copy2boot.sh"
