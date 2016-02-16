if [ "$PREFERRED_TOOLKIT" = "gtk" ]; then
    echo "[Qt]
Style=GTK+" | dd of="$R/etc/xdg/Trolltech.conf"
    chmod 644 "$R/etc/xdg/Trolltech.conf"

    if ! contains QT_STYLE "$R/etc/environment" ; then
        append "$R/etc/environment" 'QT_STYLE_OVERRIDE=GTK+'
    fi
fi
