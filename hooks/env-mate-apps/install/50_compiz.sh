install_aur_pkg compiz
no_autostart_app compiz

sed -i 's#Exec=compiz$#Exec=compiz --replace#' "/resources/HOME/.config/autostart/compiz.desktop"
