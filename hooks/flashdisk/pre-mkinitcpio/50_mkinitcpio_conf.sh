append_text "/etc/mkinitcpio.conf" <<EOF
MODULES=(squashfs vfat loop overlay btrfs ext4 ntfs)
HOOKS=(base udev modconf block rolinux keyboard shutdown)
COMPRESSION='$COMPRESSION_TYPE'
EOF

install_file resources/linux.preset "/etc/mkinitcpio.d/linux.preset"
