source ./strapfuncs.sh

install_pkg -S  --noconfirm xorg

copy /etc/X11/xorg.conf.d/00-keyboard.conf
copy /etc/X11/xorg.conf.d/10-keyboard-layout.conf
