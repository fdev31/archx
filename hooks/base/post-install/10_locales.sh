echo "${LANG} UTF-8" | sudo dd of="$R/etc/locale.gen"
sudo arch-chroot "$R" locale-gen

(cd "$R/etc" && sudo ln -sf "/usr/share/zoneinfo/${LANG_TZ}" localtime)
echo "
LANG=\"${LANG}\"
LC_CTYPE=\"${LANG}\"
LC_TIME=\"${LANG}\"
lC_COLLATE=\"${LANG}\"
LC_MONETARY=\"${LANG}\"
LC_MESSAGES=\"${LANG}\"
LC_PAPER=\"${LANG}\"
LC_NAME=\"${LANG}\"
LC_ADDRESS=\"${LANG}\"
LC_TELEPHONE=\"${LANG}\"
LC_MEASUREMENT=\"${LANG}\"
LC_IDENTIFICATION=\"${LANG}\"
LC_NUMERIC=\"C\"" | sudo dd of="$R/etc/locale.conf"

echo "
Section \"InputClass\"
    Identifier \"system-keyboard\"
    MatchIsKeyboard \"on\"
    Option \"XkbLayout\" \"${LANG_ISO2}\"
    Option \"XkbOptions\" \"terminate:ctrl_alt_bksp\"
EndSection
" | sudo dd of="$R/etc/X11/xorg.conf.d/00-keyboard.conf"
