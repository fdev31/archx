copy /etc/localtime
copy /etc/locale.gen
copy /etc/locale.conf

sudo arch-chroot "$R" locale-gen
