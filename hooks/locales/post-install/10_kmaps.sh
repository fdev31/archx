echo "Installing ${LANG_ISO2} support..."
if [ -e "resources/locales/${LANG_ISO2}.kmap" ] ; then
    install_file "resources/locales/${LANG_ISO2}.kmap" "/usr/share/kbd/keymaps/initrd.map"
fi
