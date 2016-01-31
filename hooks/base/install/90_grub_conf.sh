source ./strapfuncs.sh

sudo mkdir "$R/boot/grub" 2> /dev/null
sudo install -DT -o root -g root -m 640 /usr/share/grub/euro.pf2 "$R/boot/grub/font.pf2"
sudo install -g root -o root -m 644 resources/grub.cfg "$R/boot/grub/grub.cfg"
sudo sed -i "s/DISKLABEL/$DISKLABEL/g" "$R/boot/grub/grub.cfg"
