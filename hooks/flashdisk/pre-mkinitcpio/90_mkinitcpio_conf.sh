
sudo install -TD -o root -g root resources/linux.preset "$R/etc/mkinitcpio.d/linux.preset"

pat="# MOVABLE PATCH"

I="$R/etc/mkinitcpio.conf"

strip_end "$pat" "$I"
_FILE=$(cat "$I")
echo "$_FILE

# MOVABLE PATCH
MODULES='squashfs vfat loop overlay btrfs ext4'
HOOKS='base udev keyboard block'
COMPRESSION='$COMPRESSION_TYPE'
" | sudo dd "of=$I"
