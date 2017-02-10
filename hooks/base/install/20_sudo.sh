install_pkg  sudo

sudo install -TD -o root -g root -m 660 resources/sudo_conf_nopass "$R/etc/sudoers.d/50_nopassword"
