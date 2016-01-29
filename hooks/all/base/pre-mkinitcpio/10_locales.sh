# script-forced
source ./strapfuncs.sh
source ./configuration.sh

copy /etc/localtime
copy /etc/locale.gen
copy /etc/locale.conf

arch-chroot "$R" locale-gen
