. ./strapfuncs.sh

install_pkg -Sy --noconfirm netctl wpa_supplicant ifplugd

enable_service netctl
disable_service NetworkManager

