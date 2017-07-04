install_pkg os-prober
install_pkg grub
$SUDO mkdir -p "$R/boot/grub/fonts/" 2> /dev/null
$SUDO mkdir -p "$R/boot/grub/themes/" 2> /dev/null
$SUDO cp resources/grub/*.pf2 "$R/boot/grub/fonts/"
$SUDO cp -r resources/grub/breeze "$R/boot/grub/themes/"
install_file resources/grub/grub.cfg "/boot/grub/grub.cfg"
$SUDO sed -i "s/DISKLABEL/$DISKLABEL/g" "$R/boot/grub/grub.cfg"
$SUDO sed -i "s/STD_BOOT/$(text Standard boot)/" "$R/boot/grub/grub.cfg"
$SUDO sed -i "s/SAFE_BOOT/$(text Safe boot)/" "$R/boot/grub/grub.cfg"
$SUDO sed -i "s/RESET_BOOT/$(text Revert changes)/" "$R/boot/grub/grub.cfg"

echo 'GRUB_THEME="/boot/grub/themes/breeze/theme.txt"' | append_text "/etc/default/grub"

if [ -e "resources/locales/${LANG_ISO2}.gkb" ]; then
    install_file "resources/locales/${LANG_ISO2}.gkb" "/boot/grub/keyboard.gkb"
else
    echo "No gkb file found for this locale. Grub will have incorrect keymap."
fi
