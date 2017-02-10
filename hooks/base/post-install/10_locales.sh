sudo dd of="$R/etc/locale.gen" <<EOF
${LANG} UTF-8
en_US UTF-8
es_ES UTF-8
de_DE UTF-8
pt_PT UTF-8
EOF
sudo arch-chroot "$R" locale-gen

install_file resources/xorg.conf.d/* "/etc/X11/xorg.conf.d/"

(cd "$R/etc" && sudo ln -sf "/usr/share/zoneinfo/${LANG_TZ}" localtime)
echo "
LANG=\"${LANG}\"
LC_NUMERIC=\"C\"" | sudo dd of="$R/etc/locale.conf"

echo "
Section \"InputClass\"
    Identifier \"system-keyboard\"
    MatchIsKeyboard \"on\"
    Option \"XkbLayout\" \"${LANG_ISO2},us\"
    Option \"XkbOptions\" \"terminate:ctrl_alt_bksp\"
EndSection
" | sudo dd of="$R/etc/X11/xorg.conf.d/10-keyboard-layout.conf"
