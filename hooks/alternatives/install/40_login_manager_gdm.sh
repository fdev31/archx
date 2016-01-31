. ./strapfuncs.sh

install_pkg -S  --noconfirm gdm
sudo ln -sf /usr/lib/systemd/system/gdm.service "$R/etc/systemd/system/display-manager.service"
