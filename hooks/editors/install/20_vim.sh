if have_xorg ; then
    install_pkg gvim
else 
    install_pkg vim
fi
install_pkg vim-spell-${LANG_ISO2}
