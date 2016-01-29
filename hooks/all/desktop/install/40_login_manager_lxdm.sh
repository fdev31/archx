source ./configuration.sh

./mkbootstrap.sh install -S  --noconfirm lxdm
ln -sf /usr/lib/systemd/system/lxdm.service $R/etc/systemd/system/display-manager.service
