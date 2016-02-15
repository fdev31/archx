echo "Installing ${LANG%_*} support..."

install_file "resources/${LANG%_*}.kmap" "$R/usr/share/kbd/keymaps/initrd.map"
