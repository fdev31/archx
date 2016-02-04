
install_pkg  xorg xterm

copy /etc/X11/xorg.conf.d/00-keyboard.conf
copy /etc/X11/xorg.conf.d/10-keyboard-layout.conf

enable_service accounts-daemon
