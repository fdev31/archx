append_text "/etc/mkinitcpio.conf" <<EOF
MODULES='squashfs vfat loop overlay btrfs ext4 ntfs'
HOOKS='base udev keyboard block rolinux shutdown'
COMPRESSION='$COMPRESSION_TYPE'
EOF
