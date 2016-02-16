
install_pkg  xorg xterm xorg-xinit

copy /etc/X11/xorg.conf.d/00-keyboard.conf
copy /etc/X11/xorg.conf.d/10-keyboard-layout.conf

enable_service accounts-daemon
if [ "$PREFERRED_TOOLKIT" = "gtk" ]; then
    install_pkg gtk-engines
    echo "
[Qt]
Style=GTK+" | dd of="$R/etc/xdg/Trolltech.conf"
    chmod 644 "$R/etc/xdg/Trolltech.conf"

    if ! contains QT_STYLE "$R/etc/environment" ; then
        append "$R/etc/environment" 'QT_STYLE_OVERRIDE=GTK+'
    fi
fi

install_pkg libx264 mesa-libgl
