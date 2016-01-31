. ./strapfuncs.sh

install_pkg -S  --noconfirm lxdm
sudo ln -sf /usr/lib/systemd/system/lxdm.service $R/etc/systemd/system/display-manager.service
