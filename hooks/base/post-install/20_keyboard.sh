echo -e "KEYMAP=${LANG_ISO2}\nFONT=${LANG_TERMFONT}" | sudo dd of="$R/etc/vconsole.conf" # conv=notrunc oflag=append

