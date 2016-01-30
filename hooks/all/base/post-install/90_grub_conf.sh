source ./configuration.sh

cp /usr/share/grub/euro.pf2 "$R/boot/grub/font.pf2"

sed "s/DISKLABEL/$DISKLABEL/g" < resources/grub.cfg > "$R/boot/grub/grub.cfg"
