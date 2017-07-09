$SUDO gpg --home "$R/root" --recv-keys --keyserver sks-keyservers.net 0xDB1187B9DD5F693B
if have_xorg; then  install_pkg thunderbird-enigmail ; fi
