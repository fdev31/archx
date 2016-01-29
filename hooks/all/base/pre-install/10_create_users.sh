source ./configuration.sh

arch-chroot $R useradd -G $DEFAULT_GROUPS -m user
arch-chroot $R useradd -G $ADMIN_GROUPS -m admin

echo "root:$PASSWORD
admin:$PASSWORD
user:$PASSWORD" | sudo arch-chroot "$R" chpasswd

