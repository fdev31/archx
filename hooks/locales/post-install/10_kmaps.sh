echo "Installing ${LANG_ISO2} support..."

install_file "resources/locales/${LANG_ISO2}.kmap" "/usr/share/kbd/keymaps/initrd.map"
