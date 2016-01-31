. ./strapfuncs.sh

install_pkg -Sy --noconfirm networkmanager

sudo ln -sf /usr/lib/systemd/system/NetworkManager.service "$R/etc/systemd/system/dbus-org.freedesktop.NetworkManager.service"
sudo ln -sf /usr/lib/systemd/system/NetworkManager.service "$R/etc/systemd/system/multi-user.target.wants/NetworkManager.service"
sudo ln -sf /usr/lib/systemd/system/NetworkManager-dispatcher.service "$R/etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service"
