#install_pkg vim vim-spell-${LANG_ISO2}
install_pkg nano-syntax-highlighting-git
ln -fs /usr/share/nano-syntax-highlighting/nanorc.sample "resources/HOME/.nanorc"
sudo ln -fs /usr/share/nano-syntax-highlighting/nanorc.sample "$R/root/.nanorc"
