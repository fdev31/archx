$SUDO dd of="$R/etc/locale.gen" 2>/dev/null <<EOF
${LANG} UTF-8
fr_FR UTF-8
en_US UTF-8
es_ES UTF-8
de_DE UTF-8
it_IT UTF-8
pt_PT UTF-8
EOF

if [ -z "$CHROOT" ]; then
    $SU_$ARCHCHROOT "$R" locale-gen
else
    locale-gen
fi

make_symlink "/usr/share/zoneinfo/${LANG_TZ}" "/etc/localtime"

echo "
LANG=\"${LANG}\"
LC_NUMERIC=\"C\"" | $SUDO dd of="$R/etc/locale.conf" 2>/dev/null

if have_xorg ; then
    install_file resources/xorg.conf.d/* "/etc/X11/xorg.conf.d/"

    echo "
    Section \"InputClass\"
        Identifier \"system-keyboard\"
        MatchIsKeyboard \"on\"
        Option \"XkbLayout\" \"${LANG_ISO2},us\"
        Option \"XkbOptions\" \"terminate:ctrl_alt_bksp\"
    EndSection
    " | $SUDO dd of="$R/etc/X11/xorg.conf.d/10-keyboard-layout.conf" 2>/dev/null
fi
