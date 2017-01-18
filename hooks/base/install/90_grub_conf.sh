install_pkg os-prober
install_pkg grub
sudo mkdir -p "$R/boot/grub/fonts/" 2> /dev/null
sudo mkdir -p "$R/boot/grub/themes/" 2> /dev/null
sudo cp -r "$R/usr/share/grub/"*.pf2 "$R/boot/grub/fonts/"
sudo cp -r resources/*.pf2 "$R/boot/grub/fonts/"
sudo cp -r resources/breeze "$R/boot/grub/themes/"
install_file resources/grub.cfg "/boot/grub/grub.cfg"
sudo sed -i "s/DISKLABEL/$DISKLABEL/g" "$R/boot/grub/grub.cfg"

echo 'GRUB_THEME="/boot/grub/themes/breeze/theme.txt"' | append_text "/etc/default/grub"

if [ -e "resources/locales/${LANG_ISO2}.gkb" ]; then
    install_file "resources/locales/${LANG_ISO2}.gkb" "/boot/grub/keyboard.gkb"
else
    echo "No gkb file found for this locale. Grub will have incorrect keymap."
fi
