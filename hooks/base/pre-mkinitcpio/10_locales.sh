(cd "$R/etc" && ln -sf "/usr/share/zoneinfo/${LANG_TZ}" localtime)
echo "LANG=${LANG}
LC_NUMERIC=C" | sudo dd of="$R/etc/locale.conf"

sudo arch-chroot "$R" locale-gen
