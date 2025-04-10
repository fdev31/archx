append_text "/etc/mkinitcpio.conf" <<EOF
MODULES=(squashfs vfat loop overlay btrfs ext4 ntfs3)
HOOKS=(base udev modconf block rolinux keyboard shutdown)
COMPRESSION='xz'
EOF

install_file resources/linux.preset "/etc/mkinitcpio.d/linux.preset"
