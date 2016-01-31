. ./strapfuncs.sh

install_pkg -S  --noconfirm ssdm
sudo ln -sf /usr/lib/systemd/system/ssdm.service "$R/etc/systemd/system/display-manager.service"
