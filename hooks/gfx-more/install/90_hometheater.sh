# alternative: openpht
install_pkg kodi
install_pkg kodi-audioencoder-vorbis kodi-audioencoder-lame

echo "needs_root_rights = yes" | sudo dd of="$R/etc/X11/Xwrapper.config"

sudo useradd --system -R "$R" -G $DEFAULT_GROUPS -m kodiuser

install_pkg streamstudio-bin
install_pkg popcorntime-ce-bin

