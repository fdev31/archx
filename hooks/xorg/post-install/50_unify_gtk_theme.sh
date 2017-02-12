if [ "$PREFERRED_TOOLKIT" = "gtk" ]; then
    echo "[Qt]
Style=GTK+" | sudo dd of="$R/etc/xdg/Trolltech.conf" 2>/dev/null && echo "Qt style = gtk"
    sudo chmod 644 "$R/etc/xdg/Trolltech.conf"

    append_text "/etc/environment" <<EOF
QT_STYLE_OVERRIDE=GTK+
EOF
fi

install_pkg breeze
install_pkg breeze-gtk
install_pkg breeze-kde4
