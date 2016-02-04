install_pkg grub
sudo mkdir -p "$R/boot/grub/fonts/" 2> /dev/null
sudo cp -r "$R/usr/share/grub/"*.pf2 "$R/boot/grub/fonts/"
sudo cp -r "$R/usr/share/grub/themes" "$R/boot/grub/"
sudo install -g root -o root -m 644 resources/grub.cfg "$R/boot/grub/grub.cfg"
sudo sed -i "s/DISKLABEL/$DISKLABEL/g" "$R/boot/grub/grub.cfg"
