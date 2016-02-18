echo "Installing ${LANG_ISO2} support..."

install_file "resources/${LANG_ISO2}.kmap" "$R/usr/share/kbd/keymaps/initrd.map"
