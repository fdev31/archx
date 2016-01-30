. ./strapfuncs.sh

install_pkg -Sy --noconfirm networkmanager

ln -sf /usr/lib/systemd/system/NetworkManager.service "$R/etc/systemd/system/dbus-org.freedesktop.NetworkManager.service"
ln -sf /usr/lib/systemd/system/NetworkManager.service "$R/etc/systemd/system/multi-user.target.wants/NetworkManager.service"
ln -sf /usr/lib/systemd/system/NetworkManager-dispatcher.service "$R/etc/systemd/system/dbus-org.freedesktop.nm-dispatcher.service"
