# script-forced
source ./configuration.sh

install -TD -o root -g root resources/linux.preset $R/etc/mkinitcpio.d/linux.preset

pat="# MOVABLE PATCH"

I="$R/etc/mkinitcpio.conf"

sed -i "/^$pat/,$ d" "$I"
echo '# MOVABLE PATCH' >> "$I"
echo 'MODULES="squashfs vfat loop overlay"' >> "$I"
echo 'HOOKS="base udev keyboard block"' >> "$I"
echo 'COMPRESSION="xz"' >> "$I"
