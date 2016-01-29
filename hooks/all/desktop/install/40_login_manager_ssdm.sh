source ./configuration.sh
./mkbootstrap.sh install -S  --noconfirm ssdm
ln -sf /usr/lib/systemd/system/ssdm.service $R/etc/systemd/system/display-manager.service
