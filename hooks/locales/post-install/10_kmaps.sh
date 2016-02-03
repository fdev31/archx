. ./strapfuncs.sh
echo "Installing ${LANG%_*} support..."

sudo install -o root -g root -m 644 "resources/${LANG%_*}.kmap" "$R/usr/share/kbd/keymaps/initrd.map"
